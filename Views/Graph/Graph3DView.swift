import SwiftUI
@preconcurrency import SceneKit

struct Graph3DSnapshot {
    let levelId: String
    let gridRange: ClosedRange<Double>
    let marbleX: Double
    let marbleY: Double
    let stars: [StarSnapshot]
    let isRunning: Bool
    let trailPoints: [GraphPoint]
    let curvePoints: [CGPoint]

    struct StarSnapshot {
        let id: UUID
        let x: Double
        let y: Double
        let isCollected: Bool
    }
}

struct Graph3DView: UIViewRepresentable {
    @ObservedObject var viewModel: GameViewModel
    let size: CGSize

    private var snapshot: Graph3DSnapshot {
        let range = viewModel.currentLevel.gridRange
        let lower = range.lowerBound
        let upper = range.upperBound
        let span = upper - lower
        let steps = 150

        var curvePoints: [CGPoint] = []
        for s in 0...steps {
            let x = lower + span * Double(s) / Double(steps)
            let y = viewModel.evaluateFunction(at: x)
            if y.isFinite && abs(y) < 50 {
                curvePoints.append(CGPoint(x: x, y: y))
            }
        }

        let starSnapshots = viewModel.stars.map {
            Graph3DSnapshot.StarSnapshot(
                id: $0.id,
                x: $0.position.x,
                y: $0.position.y,
                isCollected: $0.isCollected
            )
        }

        return Graph3DSnapshot(
            levelId: viewModel.currentLevel.id,
            gridRange: range,
            marbleX: viewModel.marbleX,
            marbleY: viewModel.marbleY,
            stars: starSnapshots,
            isRunning: viewModel.isRunning,
            trailPoints: viewModel.marbleTrail,
            curvePoints: curvePoints
        )
    }

    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.backgroundColor = .clear
        scnView.antialiasingMode = .multisampling2X
        scnView.allowsCameraControl = true
        scnView.autoenablesDefaultLighting = false
        scnView.isJitteringEnabled = false
        scnView.preferredFramesPerSecond = 60
        scnView.rendersContinuously = false

        let scene = SCNScene()
        scene.background.contents = UIColor.clear
        scnView.scene = scene

        setupLights(scene: scene)
        setupCamera(scene: scene)

        context.coordinator.scnView = scnView
        context.coordinator.fullRebuild(snapshot: snapshot)

        return scnView
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
        context.coordinator.updateOrRebuild(snapshot: snapshot)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    private func setupCamera(scene: SCNScene) {
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.fieldOfView = 50
        cameraNode.camera?.zNear = 0.1
        cameraNode.camera?.zFar = 200
        cameraNode.camera?.motionBlurIntensity = 0.1
        cameraNode.position = SCNVector3(x: 0, y: 14, z: 16)
        cameraNode.look(at: SCNVector3(x: 0, y: 0, z: 0))
        cameraNode.name = "camera"
        scene.rootNode.addChildNode(cameraNode)
    }

    private func setupLights(scene: SCNScene) {
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient
        ambientLight.light?.color = UIColor(white: 0.4, alpha: 1)
        ambientLight.light?.intensity = 600
        ambientLight.name = "ambient"
        scene.rootNode.addChildNode(ambientLight)

        let directionalLight = SCNNode()
        directionalLight.light = SCNLight()
        directionalLight.light?.type = .directional
        directionalLight.light?.color = UIColor(red: 0.3, green: 0.8, blue: 1.0, alpha: 1)
        directionalLight.light?.intensity = 800
        directionalLight.light?.castsShadow = false
        directionalLight.position = SCNVector3(x: 5, y: 15, z: 10)
        directionalLight.look(at: SCNVector3Zero)
        directionalLight.name = "directional"
        scene.rootNode.addChildNode(directionalLight)

        let fillLight = SCNNode()
        fillLight.light = SCNLight()
        fillLight.light?.type = .omni
        fillLight.light?.color = UIColor(red: 1.0, green: 0.4, blue: 0.7, alpha: 1)
        fillLight.light?.intensity = 300
        fillLight.position = SCNVector3(x: -8, y: 8, z: -5)
        fillLight.name = "fill"
        scene.rootNode.addChildNode(fillLight)
    }

    @MainActor class Coordinator {
        weak var scnView: SCNView?

        private var currentLevelId: String = ""
        private var curveNode: SCNNode?
        private var curveGlowNode: SCNNode?
        private var marbleNode: SCNNode?
        private var starNodes: [String: SCNNode] = [:]
        private var trailNodes: [SCNNode] = []
        private var helperNodes: [SCNNode] = []
        private var contentNode: SCNNode?

        private let marbleRadius: Float = 0.3
        private let starZOffset: Float = 0.3
        private let reservedNames: Set<String> = ["camera", "directional", "fill", "ambient"]

        private var animatedCollectedStarIds: Set<String> = []

        private var lastMarbleX: Float = -999
        private var lastMarbleY: Float = -999
        private var lastTrailCount: Int = 0
        private var wasRunning: Bool = false

        private var lastCurveUpdateTime: CFTimeInterval = 0
        private let curveUpdateInterval: CFTimeInterval = 0.05
        private var lastCurveHash: Int = 0

        func updateOrRebuild(snapshot: Graph3DSnapshot) {
            if snapshot.levelId != currentLevelId {
                fullRebuild(snapshot: snapshot)
            } else {
                incrementalUpdate(snapshot: snapshot)
            }
        }

        func fullRebuild(snapshot: Graph3DSnapshot) {
            guard let scene = scnView?.scene else { return }

            currentLevelId = snapshot.levelId
            animatedCollectedStarIds.removeAll()
            lastMarbleX = -999
            lastMarbleY = -999
            lastTrailCount = 0
            wasRunning = false
            lastCurveHash = 0
            lastCurveUpdateTime = 0

            contentNode?.removeFromParentNode()
            contentNode = nil
            curveNode = nil
            curveGlowNode = nil
            marbleNode = nil
            starNodes.removeAll()
            trailNodes.removeAll()
            helperNodes.removeAll()

            let content = SCNNode()
            content.name = "content"
            scene.rootNode.addChildNode(content)
            contentNode = content

            let lower = Float(snapshot.gridRange.lowerBound)
            let upper = Float(snapshot.gridRange.upperBound)
            let span = upper - lower

            buildGrid(parent: content, lower: lower, upper: upper, span: span)
            buildAxes(parent: content, lower: lower, upper: upper)
            updateCurveGeometry(parent: content, snapshot: snapshot, force: true)
            buildAllStars(parent: content, snapshot: snapshot)
            buildMarble(parent: content, snapshot: snapshot)
        }

        private func incrementalUpdate(snapshot: Graph3DSnapshot) {
            guard let content = contentNode else {
                fullRebuild(snapshot: snapshot)
                return
            }

            updateMarbleSmooth(snapshot: snapshot)
            updateStarStates(snapshot: snapshot)

            if !snapshot.isRunning {
                let now = CACurrentMediaTime()
                if now - lastCurveUpdateTime >= curveUpdateInterval {
                    updateCurveGeometry(parent: content, snapshot: snapshot, force: false)
                    lastCurveUpdateTime = now
                }
            }

            if snapshot.isRunning {
                addTrailPoints(parent: content, snapshot: snapshot)
            }

            if snapshot.isRunning && !wasRunning {
                onSimulationStart(snapshot: snapshot)
            }

            let allNotCollected = snapshot.stars.allSatisfy { !$0.isCollected }
            if allNotCollected && !animatedCollectedStarIds.isEmpty {
                animatedCollectedStarIds.removeAll()
                clearTrail()
                buildAllStars(parent: content, snapshot: snapshot)
                lastMarbleX = -999
                lastMarbleY = -999
            }

            wasRunning = snapshot.isRunning
        }

        private func onSimulationStart(snapshot: Graph3DSnapshot) {
            guard let marble = marbleNode else { return }
            let gx = Float(snapshot.marbleX)
            let gy = Float(snapshot.marbleY)
            marble.removeAction(forKey: "pathFollow")
            marble.position = SCNVector3(gx, gy, marbleRadius + 0.05)
            lastMarbleX = gx
            lastMarbleY = gy
        }

        private func updateMarbleSmooth(snapshot: Graph3DSnapshot) {
            guard let marble = marbleNode else { return }

            let targetX = Float(snapshot.marbleX)
            let targetY = Float(snapshot.marbleY)
            let targetZ = marbleRadius + 0.05

            if abs(targetX - lastMarbleX) < 0.001 && abs(targetY - lastMarbleY) < 0.001 {
                return
            }

            let dx = targetX - lastMarbleX
            let dy = targetY - lastMarbleY

            if snapshot.isRunning {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.05
                SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .linear)
                marble.position = SCNVector3(targetX, targetY, targetZ)

                let moveDistance = sqrt(dx * dx + dy * dy)
                let rollAngle = moveDistance / marbleRadius
                let moveAngle = atan2(dy, dx)
                let rollAxisX = -sin(moveAngle)
                let rollAxisY = cos(moveAngle)
                let currentTransform = marble.transform
                let rotation = SCNMatrix4MakeRotation(rollAngle, rollAxisX, rollAxisY, 0)
                marble.transform = SCNMatrix4Mult(rotation, currentTransform)
                SCNTransaction.commit()
            } else {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.08
                SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .linear)
                marble.position = SCNVector3(targetX, targetY, targetZ)
                SCNTransaction.commit()
            }

            lastMarbleX = targetX
            lastMarbleY = targetY
        }

        private func updateCurveGeometry(parent: SCNNode, snapshot: Graph3DSnapshot, force: Bool) {
            let points = snapshot.curvePoints

            var hash = points.count
            if let first = points.first {
                hash ^= Int(first.x * 1000)
                hash ^= Int(first.y * 1000)
            }
            if let last = points.last {
                hash ^= Int(last.x * 1000) &* 31
                hash ^= Int(last.y * 1000) &* 31
            }
            if !force && hash == lastCurveHash { return }
            lastCurveHash = hash

            guard points.count >= 2 else {
                curveNode?.isHidden = true
                curveGlowNode?.isHidden = true
                return
            }

            let curveGeo = buildTubeGeometry(points: points, radius: 0.09, segments: 10)
            let glowGeo = buildTubeGeometry(points: points, radius: 0.22, segments: 8)

            if let existingCurve = curveNode {
                existingCurve.geometry = curveGeo
                existingCurve.isHidden = false
            } else {
                let node = SCNNode(geometry: curveGeo)
                node.name = "curve"
                parent.addChildNode(node)
                curveNode = node
            }

            if let existingGlow = curveGlowNode {
                existingGlow.geometry = glowGeo
                existingGlow.isHidden = false
            } else {
                let node = SCNNode(geometry: glowGeo)
                node.name = "curveGlow"
                parent.addChildNode(node)
                curveGlowNode = node
            }
        }

        private func buildTubeGeometry(points: [CGPoint], radius: Float, segments: Int) -> SCNGeometry {
            let count = points.count
            guard count >= 2 else { return SCNGeometry() }

            let isGlow = radius > 0.15

            var vertices: [SCNVector3] = []
            var normals: [SCNVector3] = []
            var indices: [UInt32] = []

            for i in 0..<count {
                let x = Float(points[i].x)
                let y = Float(points[i].y)

                let tangent: SCNVector3
                if i == 0 {
                    let tnx = Float(points[1].x) - x
                    let tny = Float(points[1].y) - y
                    let len = sqrt(tnx * tnx + tny * tny)
                    tangent = len > 0.0001 ? SCNVector3(tnx / len, tny / len, 0) : SCNVector3(1, 0, 0)
                } else if i == count - 1 {
                    let tpx = x - Float(points[i - 1].x)
                    let tpy = y - Float(points[i - 1].y)
                    let len = sqrt(tpx * tpx + tpy * tpy)
                    tangent = len > 0.0001 ? SCNVector3(tpx / len, tpy / len, 0) : SCNVector3(1, 0, 0)
                } else {
                    let tpx = Float(points[i + 1].x) - Float(points[i - 1].x)
                    let tpy = Float(points[i + 1].y) - Float(points[i - 1].y)
                    let len = sqrt(tpx * tpx + tpy * tpy)
                    tangent = len > 0.0001 ? SCNVector3(tpx / len, tpy / len, 0) : SCNVector3(1, 0, 0)
                }

                let normal1 = SCNVector3(-tangent.y, tangent.x, 0)
                let normal2 = SCNVector3(0, 0, 1)

                for s in 0..<segments {
                    let angle = Float(s) / Float(segments) * Float.pi * 2.0
                    let cosA = cos(angle)
                    let sinA = sin(angle)

                    let vx = x + radius * (cosA * normal1.x + sinA * normal2.x)
                    let vy = y + radius * (cosA * normal1.y + sinA * normal2.y)
                    let vz: Float = radius * (cosA * normal1.z + sinA * normal2.z)

                    vertices.append(SCNVector3(vx, vy, vz))

                    let nnx = cosA * normal1.x + sinA * normal2.x
                    let nny = cosA * normal1.y + sinA * normal2.y
                    let nnz = cosA * normal1.z + sinA * normal2.z
                    normals.append(SCNVector3(nnx, nny, nnz))
                }
            }

            for i in 0..<(count - 1) {
                let ring1 = UInt32(i * segments)
                let ring2 = UInt32((i + 1) * segments)

                for s in 0..<segments {
                    let s0 = UInt32(s)
                    let s1 = UInt32((s + 1) % segments)

                    indices.append(ring1 + s0)
                    indices.append(ring2 + s0)
                    indices.append(ring1 + s1)

                    indices.append(ring1 + s1)
                    indices.append(ring2 + s0)
                    indices.append(ring2 + s1)
                }
            }

            let startCenter = UInt32(vertices.count)
            vertices.append(SCNVector3(Float(points[0].x), Float(points[0].y), 0))
            let st = tangentAt(points: points, index: 0)
            normals.append(SCNVector3(-Float(st.x), -Float(st.y), 0))
            for s in 0..<segments {
                let s1 = (s + 1) % segments
                indices.append(startCenter)
                indices.append(UInt32(s1))
                indices.append(UInt32(s))
            }

            let endCenter = UInt32(vertices.count)
            let lastIdx = count - 1
            vertices.append(SCNVector3(Float(points[lastIdx].x), Float(points[lastIdx].y), 0))
            let et = tangentAt(points: points, index: lastIdx)
            normals.append(SCNVector3(Float(et.x), Float(et.y), 0))
            let endRing = UInt32(lastIdx * segments)
            for s in 0..<segments {
                let s1 = (s + 1) % segments
                indices.append(endCenter)
                indices.append(endRing + UInt32(s))
                indices.append(endRing + UInt32(s1))
            }

            let vertexSource = SCNGeometrySource(vertices: vertices)
            let normalSource = SCNGeometrySource(normals: normals)
            let element = SCNGeometryElement(indices: indices, primitiveType: .triangles)
            let geometry = SCNGeometry(sources: [vertexSource, normalSource], elements: [element])

            let mat = SCNMaterial()
            if isGlow {
                mat.diffuse.contents = UIColor(red: 0.4, green: 1.0, blue: 0.6, alpha: 0.1)
                mat.emission.contents = UIColor(red: 0.4, green: 1.0, blue: 0.6, alpha: 0.08)
                mat.lightingModel = .constant
                mat.isDoubleSided = true
            } else {
                mat.diffuse.contents = UIColor(red: 0.35, green: 0.95, blue: 0.55, alpha: 1.0)
                mat.emission.contents = UIColor(red: 0.4, green: 1.0, blue: 0.6, alpha: 0.5)
                mat.specular.contents = UIColor.white
                mat.shininess = 50
                mat.fresnelExponent = 1.5
                mat.lightingModel = .phong
                mat.isDoubleSided = true
            }
            geometry.materials = [mat]

            return geometry
        }

        private func tangentAt(points: [CGPoint], index: Int) -> CGPoint {
            let count = points.count
            if index == 0 && count > 1 {
                return CGPoint(x: points[1].x - points[0].x, y: points[1].y - points[0].y)
            } else if index == count - 1 && count > 1 {
                return CGPoint(x: points[count - 1].x - points[count - 2].x, y: points[count - 1].y - points[count - 2].y)
            } else if index > 0 && index < count - 1 {
                return CGPoint(x: points[index + 1].x - points[index - 1].x, y: points[index + 1].y - points[index - 1].y)
            }
            return CGPoint(x: 1, y: 0)
        }

        private func buildGrid(parent: SCNNode, lower: Float, upper: Float, span: Float) {
            let gridParent = SCNNode()
            gridParent.name = "grid"

            let planeGeo = SCNPlane(width: CGFloat(span + 2), height: CGFloat(span + 2))
            let frontMat = SCNMaterial()
            frontMat.diffuse.contents = UIColor(red: 0.1, green: 0.15, blue: 0.35, alpha: 1.0)
            frontMat.emission.contents = UIColor(red: 0.08, green: 0.1, blue: 0.25, alpha: 0.4)
            frontMat.transparency = 0.3
            frontMat.isDoubleSided = true
            frontMat.lightingModel = .constant
            frontMat.writesToDepthBuffer = false
            frontMat.readsFromDepthBuffer = true
            frontMat.blendMode = .screen
            planeGeo.materials = [frontMat]

            let planeNode = SCNNode(geometry: planeGeo)
            planeNode.eulerAngles.x = -.pi / 2
            planeNode.position = SCNVector3((lower + upper) / 2, -0.005, 0)
            planeNode.renderingOrder = -10
            gridParent.addChildNode(planeNode)

            let gridGeo = buildGridLinesGeometry(lower: lower, upper: upper)
            let gridLinesNode = SCNNode(geometry: gridGeo)
            gridLinesNode.renderingOrder = 1
            gridParent.addChildNode(gridLinesNode)

            let xAxisGeo = buildSingleLineGeometry(
                from: SCNVector3(lower, 0, 0.005), to: SCNVector3(upper, 0, 0.005), thickness: 0.04
            )
            let xAxisMat = SCNMaterial()
            xAxisMat.diffuse.contents = UIColor(red: 0.3, green: 0.85, blue: 1.0, alpha: 0.9)
            xAxisMat.emission.contents = UIColor(red: 0.3, green: 0.85, blue: 1.0, alpha: 0.6)
            xAxisMat.isDoubleSided = true
            xAxisMat.lightingModel = .constant
            xAxisMat.writesToDepthBuffer = false
            xAxisMat.readsFromDepthBuffer = false
            xAxisMat.blendMode = .add
            xAxisGeo.materials = [xAxisMat]
            let xAxisNode = SCNNode(geometry: xAxisGeo)
            xAxisNode.renderingOrder = 2
            gridParent.addChildNode(xAxisNode)

            let yAxisGeo = buildSingleLineGeometry(
                from: SCNVector3(0, lower, 0.005), to: SCNVector3(0, upper, 0.005), thickness: 0.04
            )
            let yAxisMat = SCNMaterial()
            yAxisMat.diffuse.contents = UIColor(red: 0.4, green: 1.0, blue: 0.65, alpha: 0.9)
            yAxisMat.emission.contents = UIColor(red: 0.4, green: 1.0, blue: 0.65, alpha: 0.6)
            yAxisMat.isDoubleSided = true
            yAxisMat.lightingModel = .constant
            yAxisMat.writesToDepthBuffer = false
            yAxisMat.readsFromDepthBuffer = false
            yAxisMat.blendMode = .add
            yAxisGeo.materials = [yAxisMat]
            let yAxisNode = SCNNode(geometry: yAxisGeo)
            yAxisNode.renderingOrder = 2
            gridParent.addChildNode(yAxisNode)

            let intLower = Int(lower)
            let intUpper = Int(upper)
            for i in intLower...intUpper {
                guard i != 0 && i % 2 == 0 else { continue }
                let fi = Float(i)
                let xLabel = createTextNode(
                    text: "\(i)", position: SCNVector3(fi, lower - 0.6, 0.1),
                    color: UIColor(red: 0.3, green: 0.8, blue: 1.0, alpha: 0.7)
                )
                gridParent.addChildNode(xLabel)

                let yLabel = createTextNode(
                    text: "\(i)", position: SCNVector3(lower - 0.6, fi, 0.1),
                    color: UIColor(red: 0.4, green: 1.0, blue: 0.6, alpha: 0.7)
                )
                gridParent.addChildNode(yLabel)
            }

            parent.addChildNode(gridParent)
        }

        private func buildGridLinesGeometry(lower: Float, upper: Float) -> SCNGeometry {
            var vertices: [SCNVector3] = []
            var indices: [UInt32] = []
            let thickness: Float = 0.015
            let z: Float = 0.02

            let intLower = Int(lower)
            let intUpper = Int(upper)

            for i in intLower...intUpper {
                if i == 0 { continue }
                let fi = Float(i)

                let idx = UInt32(vertices.count)
                vertices.append(SCNVector3(lower, fi - thickness, z))
                vertices.append(SCNVector3(lower, fi + thickness, z))
                vertices.append(SCNVector3(upper, fi + thickness, z))
                vertices.append(SCNVector3(upper, fi - thickness, z))
                indices.append(contentsOf: [idx, idx+1, idx+2, idx, idx+2, idx+3])

                let idxB = UInt32(vertices.count)
                vertices.append(SCNVector3(lower, fi - thickness, -z))
                vertices.append(SCNVector3(lower, fi + thickness, -z))
                vertices.append(SCNVector3(upper, fi + thickness, -z))
                vertices.append(SCNVector3(upper, fi - thickness, -z))
                indices.append(contentsOf: [idxB, idxB+2, idxB+1, idxB, idxB+3, idxB+2])

                let idx2 = UInt32(vertices.count)
                vertices.append(SCNVector3(fi - thickness, lower, z))
                vertices.append(SCNVector3(fi + thickness, lower, z))
                vertices.append(SCNVector3(fi + thickness, upper, z))
                vertices.append(SCNVector3(fi - thickness, upper, z))
                indices.append(contentsOf: [idx2, idx2+1, idx2+2, idx2, idx2+2, idx2+3])

                let idx2B = UInt32(vertices.count)
                vertices.append(SCNVector3(fi - thickness, lower, -z))
                vertices.append(SCNVector3(fi + thickness, lower, -z))
                vertices.append(SCNVector3(fi + thickness, upper, -z))
                vertices.append(SCNVector3(fi - thickness, upper, -z))
                indices.append(contentsOf: [idx2B, idx2B+2, idx2B+1, idx2B, idx2B+3, idx2B+2])
            }

            let normalsArr = [SCNVector3](repeating: SCNVector3(0, 0, 1), count: vertices.count)
            let vertexSource = SCNGeometrySource(vertices: vertices)
            let normalSource = SCNGeometrySource(normals: normalsArr)
            let element = SCNGeometryElement(indices: indices, primitiveType: .triangles)
            let geo = SCNGeometry(sources: [vertexSource, normalSource], elements: [element])

            let mat = SCNMaterial()
            mat.diffuse.contents = UIColor(red: 0.5, green: 0.75, blue: 1.0, alpha: 0.5)
            mat.emission.contents = UIColor(red: 0.4, green: 0.6, blue: 1.0, alpha: 0.3)
            mat.lightingModel = .constant
            mat.isDoubleSided = true
            mat.writesToDepthBuffer = false
            mat.readsFromDepthBuffer = false
            mat.blendMode = .add
            geo.materials = [mat]

            return geo
        }

        private func buildSingleLineGeometry(from: SCNVector3, to: SCNVector3, thickness: Float) -> SCNGeometry {
            let dx = to.x - from.x
            let dy = to.y - from.y
            let len = sqrt(dx * dx + dy * dy)
            guard len > 0.001 else { return SCNGeometry() }

            let nx = -dy / len * thickness / 2
            let ny = dx / len * thickness / 2

            let vertices: [SCNVector3] = [
                SCNVector3(from.x + nx, from.y + ny, from.z),
                SCNVector3(from.x - nx, from.y - ny, from.z),
                SCNVector3(to.x - nx, to.y - ny, to.z),
                SCNVector3(to.x + nx, to.y + ny, to.z)
            ]
            let normalsArr = [SCNVector3](repeating: SCNVector3(0, 0, 1), count: 4)
            let indices: [UInt32] = [0, 1, 2, 0, 2, 3]

            let vertexSource = SCNGeometrySource(vertices: vertices)
            let normalSource = SCNGeometrySource(normals: normalsArr)
            let element = SCNGeometryElement(indices: indices, primitiveType: .triangles)
            return SCNGeometry(sources: [vertexSource, normalSource], elements: [element])
        }

        private func buildAxes(parent: SCNNode, lower: Float, upper: Float) {
            let xAxis = buildSingleLineGeometry(
                from: SCNVector3(lower - 0.5, 0, 0.01),
                to: SCNVector3(upper + 0.5, 0, 0.01),
                thickness: 0.05
            )
            let xMat = SCNMaterial()
            xMat.diffuse.contents = UIColor(red: 0.3, green: 0.85, blue: 1.0, alpha: 0.9)
            xMat.emission.contents = UIColor(red: 0.3, green: 0.85, blue: 1.0, alpha: 0.6)
            xMat.isDoubleSided = true
            xMat.lightingModel = .constant
            xMat.writesToDepthBuffer = false
            xMat.readsFromDepthBuffer = false
            xMat.blendMode = .add
            xAxis.materials = [xMat]
            let xAxisNode = SCNNode(geometry: xAxis)
            xAxisNode.renderingOrder = 2
            parent.addChildNode(xAxisNode)

            let yAxis = buildSingleLineGeometry(
                from: SCNVector3(0, lower - 0.5, 0.01),
                to: SCNVector3(0, upper + 0.5, 0.01),
                thickness: 0.05
            )
            let yMat = SCNMaterial()
            yMat.diffuse.contents = UIColor(red: 0.4, green: 1.0, blue: 0.65, alpha: 0.9)
            yMat.emission.contents = UIColor(red: 0.4, green: 1.0, blue: 0.65, alpha: 0.6)
            yMat.isDoubleSided = true
            yMat.lightingModel = .constant
            yMat.writesToDepthBuffer = false
            yMat.readsFromDepthBuffer = false
            yMat.blendMode = .add
            yAxis.materials = [yMat]
            let yAxisNode = SCNNode(geometry: yAxis)
            yAxisNode.renderingOrder = 2
            parent.addChildNode(yAxisNode)

            let xLbl = createTextNode(
                text: "x", position: SCNVector3(upper + 1.0, -0.3, 0.1),
                color: UIColor(red: 0.3, green: 0.8, blue: 1.0, alpha: 1.0), size: 0.5
            )
            parent.addChildNode(xLbl)

            let yLbl = createTextNode(
                text: "y", position: SCNVector3(-0.3, upper + 1.0, 0.1),
                color: UIColor(red: 0.4, green: 1.0, blue: 0.6, alpha: 1.0), size: 0.5
            )
            parent.addChildNode(yLbl)
        }

        private func buildAllStars(parent: SCNNode, snapshot: Graph3DSnapshot) {
            for (_, node) in starNodes { node.removeFromParentNode() }
            starNodes.removeAll()
            for node in helperNodes { node.removeFromParentNode() }
            helperNodes.removeAll()

            for star in snapshot.stars {
                let starNode = createStarNode(star: star)
                let key = star.id.uuidString
                parent.addChildNode(starNode)
                starNodes[key] = starNode

                if !star.isCollected {
                    addStarHelpers(parent: parent, star: star)
                }
            }
        }

        private func createStarNode(star: Graph3DSnapshot.StarSnapshot) -> SCNNode {
            let graphX = Float(star.x)
            let graphY = Float(star.y)
            let starNode = SCNNode()
            starNode.name = "star_\(star.id.uuidString)"

            if star.isCollected {
                let checkSphere = SCNSphere(radius: 0.18)
                checkSphere.segmentCount = 12
                let mat = SCNMaterial()
                mat.diffuse.contents = UIColor(red: 0.4, green: 1.0, blue: 0.6, alpha: 0.6)
                mat.emission.contents = UIColor(red: 0.4, green: 1.0, blue: 0.6, alpha: 0.4)
                checkSphere.materials = [mat]
                starNode.geometry = checkSphere
                starNode.position = SCNVector3(graphX, graphY, starZOffset)
                starNode.opacity = 0.6
            } else {
                let starGeo = SCNSphere(radius: 0.28)
                starGeo.segmentCount = 8
                let starMat = SCNMaterial()
                starMat.diffuse.contents = UIColor(red: 1.0, green: 0.85, blue: 0.3, alpha: 1.0)
                starMat.emission.contents = UIColor(red: 1.0, green: 0.85, blue: 0.3, alpha: 0.9)
                starMat.specular.contents = UIColor.white
                starMat.shininess = 60
                starGeo.materials = [starMat]
                starNode.geometry = starGeo
                starNode.position = SCNVector3(graphX, graphY, starZOffset)

                let glowSphere = SCNSphere(radius: 0.5)
                glowSphere.segmentCount = 8
                let glowMat = SCNMaterial()
                glowMat.diffuse.contents = UIColor(red: 1.0, green: 0.9, blue: 0.3, alpha: 0.1)
                glowMat.emission.contents = UIColor(red: 1.0, green: 0.9, blue: 0.3, alpha: 0.12)
                glowMat.isDoubleSided = true
                glowMat.lightingModel = .constant
                glowSphere.materials = [glowMat]
                let glowNode = SCNNode(geometry: glowSphere)
                glowNode.name = "glow"
                starNode.addChildNode(glowNode)

                starNode.runAction(SCNAction.repeatForever(SCNAction.sequence([
                    SCNAction.moveBy(x: 0, y: 0, z: 0.15, duration: 1.0),
                    SCNAction.moveBy(x: 0, y: 0, z: -0.15, duration: 1.0)
                ])))
                starNode.runAction(SCNAction.repeatForever(
                    SCNAction.rotateBy(x: 0, y: 0, z: .pi * 2, duration: 4)
                ))
                glowNode.runAction(SCNAction.repeatForever(SCNAction.sequence([
                    SCNAction.scale(to: 1.2, duration: 0.8),
                    SCNAction.scale(to: 1.0, duration: 0.8)
                ])))
            }

            return starNode
        }

        private func addStarHelpers(parent: SCNNode, star: Graph3DSnapshot.StarSnapshot) {
            let graphX = Float(star.x)
            let graphY = Float(star.y)

            let crossGeo = buildCrosshairGeometry(x: graphX, y: graphY, size: 0.6, thickness: 0.015)
            let crossMat = SCNMaterial()
            crossMat.diffuse.contents = UIColor(red: 1.0, green: 0.85, blue: 0.3, alpha: 0.25)
            crossMat.emission.contents = UIColor(red: 1.0, green: 0.85, blue: 0.3, alpha: 0.1)
            crossMat.lightingModel = .constant
            crossMat.isDoubleSided = true
            crossMat.writesToDepthBuffer = false
            crossMat.readsFromDepthBuffer = false
            crossGeo.materials = [crossMat]
            let crossNode = SCNNode(geometry: crossGeo)
            crossNode.renderingOrder = 1
            parent.addChildNode(crossNode)
            helperNodes.append(crossNode)

            let dotSphere = SCNSphere(radius: 0.06)
            dotSphere.segmentCount = 8
            let dotMat = SCNMaterial()
            dotMat.diffuse.contents = UIColor(red: 1.0, green: 0.85, blue: 0.3, alpha: 0.5)
            dotMat.emission.contents = UIColor(red: 1.0, green: 0.85, blue: 0.3, alpha: 0.3)
            dotSphere.materials = [dotMat]
            let dotNode = SCNNode(geometry: dotSphere)
            dotNode.position = SCNVector3(graphX, graphY, -0.01)
            parent.addChildNode(dotNode)
            helperNodes.append(dotNode)
        }

        private func buildCrosshairGeometry(x: Float, y: Float, size: Float, thickness: Float) -> SCNGeometry {
            let half = size / 2
            let t = thickness / 2
            let z: Float = -0.01

            let vertices: [SCNVector3] = [
                SCNVector3(x - half, y - t, z), SCNVector3(x - half, y + t, z),
                SCNVector3(x + half, y + t, z), SCNVector3(x + half, y - t, z),
                SCNVector3(x - t, y - half, z), SCNVector3(x + t, y - half, z),
                SCNVector3(x + t, y + half, z), SCNVector3(x - t, y + half, z),
            ]
            let normalsArr = [SCNVector3](repeating: SCNVector3(0, 0, 1), count: 8)
            let indices: [UInt32] = [0, 1, 2, 0, 2, 3, 4, 5, 6, 4, 6, 7]

            let vertexSource = SCNGeometrySource(vertices: vertices)
            let normalSource = SCNGeometrySource(normals: normalsArr)
            let element = SCNGeometryElement(indices: indices, primitiveType: .triangles)
            return SCNGeometry(sources: [vertexSource, normalSource], elements: [element])
        }

        private func updateStarStates(snapshot: Graph3DSnapshot) {
            for star in snapshot.stars {
                let key = star.id.uuidString
                guard let node = starNodes[key] else { continue }

                if star.isCollected && !animatedCollectedStarIds.contains(key) {
                    animatedCollectedStarIds.insert(key)
                    node.removeAllActions()

                    let burstScale = SCNAction.sequence([
                        SCNAction.scale(to: 1.5, duration: 0.1),
                        SCNAction.scale(to: 0, duration: 0.25)
                    ])
                    let fadeOut = SCNAction.fadeOut(duration: 0.3)

                    let capturedNode = node
                    let capturedKey = key
                    let capturedStarX = star.x
                    let capturedStarY = star.y
                    let capturedZOffset = starZOffset

                    capturedNode.runAction(SCNAction.group([burstScale, fadeOut])) { [weak self] in
                        DispatchQueue.main.async {
                            capturedNode.removeAllActions()
                            capturedNode.removeFromParentNode()
                            capturedNode.childNodes.forEach { $0.removeFromParentNode() }

                            let checkSphere = SCNSphere(radius: 0.18)
                            checkSphere.segmentCount = 12
                            let mat = SCNMaterial()
                            mat.diffuse.contents = UIColor(red: 0.4, green: 1.0, blue: 0.6, alpha: 0.6)
                            mat.emission.contents = UIColor(red: 0.4, green: 1.0, blue: 0.6, alpha: 0.4)
                            checkSphere.materials = [mat]

                            let collectedNode = SCNNode(geometry: checkSphere)
                            collectedNode.position = SCNVector3(Float(capturedStarX), Float(capturedStarY), capturedZOffset)
                            collectedNode.opacity = 0
                            collectedNode.name = "star_\(capturedKey)_collected"

                            self?.contentNode?.addChildNode(collectedNode)
                            self?.starNodes[capturedKey] = collectedNode
                            collectedNode.runAction(SCNAction.fadeIn(duration: 0.3))
                        }
                    }
                }
            }
        }

        private func buildMarble(parent: SCNNode, snapshot: Graph3DSnapshot) {
            marbleNode?.removeFromParentNode()

            let graphX = Float(snapshot.marbleX)
            let graphY = Float(snapshot.marbleY)

            let marbleSphere = SCNSphere(radius: CGFloat(marbleRadius))
            marbleSphere.segmentCount = 32
            let marbleMat = SCNMaterial()
            marbleMat.diffuse.contents = UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 0.85)
            marbleMat.specular.contents = UIColor.white
            marbleMat.shininess = 80
            marbleMat.reflective.contents = UIColor(red: 0.3, green: 0.8, blue: 1.0, alpha: 0.3)
            marbleMat.fresnelExponent = 3
            marbleMat.transparency = 0.9
            marbleMat.isDoubleSided = true
            marbleSphere.materials = [marbleMat]

            let marble = SCNNode(geometry: marbleSphere)
            marble.name = "marble"
            marble.position = SCNVector3(graphX, graphY, marbleRadius + 0.05)

            let coreSphere = SCNSphere(radius: CGFloat(marbleRadius * 0.45))
            coreSphere.segmentCount = 16
            let coreMat = SCNMaterial()
            coreMat.diffuse.contents = UIColor(red: 0.4, green: 0.85, blue: 1.0, alpha: 1.0)
            coreMat.emission.contents = UIColor(red: 0.3, green: 0.8, blue: 1.0, alpha: 0.8)
            coreSphere.materials = [coreMat]
            marble.addChildNode(SCNNode(geometry: coreSphere))

            let outerGlow = SCNSphere(radius: CGFloat(marbleRadius * 1.8))
            outerGlow.segmentCount = 12
            let outerMat = SCNMaterial()
            outerMat.diffuse.contents = UIColor(red: 0.3, green: 0.8, blue: 1.0, alpha: 0.06)
            outerMat.emission.contents = UIColor(red: 0.3, green: 0.8, blue: 1.0, alpha: 0.08)
            outerMat.isDoubleSided = true
            outerMat.lightingModel = .constant
            outerGlow.materials = [outerMat]
            let outerNode = SCNNode(geometry: outerGlow)
            marble.addChildNode(outerNode)
            outerNode.runAction(SCNAction.repeatForever(SCNAction.sequence([
                SCNAction.scale(to: 1.15, duration: 0.5),
                SCNAction.scale(to: 1.0, duration: 0.5)
            ])))

            parent.addChildNode(marble)
            self.marbleNode = marble
            lastMarbleX = graphX
            lastMarbleY = graphY
        }

        private func addTrailPoints(parent: SCNNode, snapshot: Graph3DSnapshot) {
            let currentCount = snapshot.trailPoints.count
            guard currentCount > lastTrailCount else { return }

            let newPoints = snapshot.trailPoints.suffix(currentCount - lastTrailCount)
            lastTrailCount = currentCount

            for point in newPoints {
                let trailSphere = SCNSphere(radius: 0.035)
                trailSphere.segmentCount = 6
                let trailMat = SCNMaterial()
                trailMat.diffuse.contents = UIColor(red: 0.3, green: 0.8, blue: 1.0, alpha: 0.5)
                trailMat.emission.contents = UIColor(red: 0.3, green: 0.8, blue: 1.0, alpha: 0.4)
                trailMat.lightingModel = .constant
                trailSphere.materials = [trailMat]

                let trailNode = SCNNode(geometry: trailSphere)
                trailNode.position = SCNVector3(Float(point.x), Float(point.y), marbleRadius * 0.3)
                parent.addChildNode(trailNode)
                trailNodes.append(trailNode)

                trailNode.runAction(SCNAction.sequence([
                    SCNAction.wait(duration: 3),
                    SCNAction.fadeOut(duration: 1.5),
                    SCNAction.removeFromParentNode()
                ]))
            }

            while trailNodes.count > 150 {
                trailNodes.removeFirst().removeFromParentNode()
            }
        }

        private func clearTrail() {
            for node in trailNodes { node.removeFromParentNode() }
            trailNodes.removeAll()
            lastTrailCount = 0
        }

        private func createTextNode(text: String, position: SCNVector3, color: UIColor, size: CGFloat = 0.3) -> SCNNode {
            let textGeo = SCNText(string: text, extrusionDepth: 0.01)
            textGeo.font = UIFont.systemFont(ofSize: size, weight: .bold)
            textGeo.flatness = 0.2
            let mat = SCNMaterial()
            mat.diffuse.contents = color
            mat.emission.contents = color.withAlphaComponent(0.5)
            mat.lightingModel = .constant
            textGeo.materials = [mat]

            let node = SCNNode(geometry: textGeo)
            node.position = position
            let (minB, maxB) = node.boundingBox
            node.pivot = SCNMatrix4MakeTranslation((maxB.x - minB.x) / 2, (maxB.y - minB.y) / 2, 0)
            let constraint = SCNBillboardConstraint()
            constraint.freeAxes = [.X, .Y]
            node.constraints = [constraint]
            return node
        }
    }
}

