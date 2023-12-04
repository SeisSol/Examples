import gmsh
import numpy as np

# mesh sizes
h_domain = 5e3
h_fault = 1000.0
h_nucl = 500.0
# dip angle
dip = 60.0
dip_rad = dip * np.pi / 180.0

# fault size
l_f = 30e3
w_f = 15e3

# nucleation position
x_n = 0e3
z_n = -12e3
# nucleation length and width
l_n = 3e3
w_n = 3e3

# domain dimensions 
x0, x1 = -45e3, 45e3
y0, y1 = -36e3, 36e3
z0, z1 = -42e3, 0

gmsh.initialize()
gmsh.model.add("tpv12")

# We can log all messages for further processing with:
gmsh.logger.start()

# We first create two cubes:
box = gmsh.model.occ.addBox(x0, y0, z0, x1 - x0, y1 - y0, z1 - z0)
fault = gmsh.model.occ.addRectangle(-l_f / 2, -w_f, 0, l_f, w_f)

nucl = gmsh.model.occ.addRectangle(x_n - l_n / 2, z_n - w_n / 2, 0, l_n, w_n)
gmsh.model.occ.rotate([(2, fault), (2, nucl)], 0, 0, 0, 1.0, 0, 0.0, dip_rad)
#gmsh.model.occ.translate([(2, fault), (2, nucl)], 0.0, 0, 1000.0)

ov, ovv = gmsh.model.occ.fragment([(3, box)], [(2, fault), (2, nucl)])
gmsh.model.occ.synchronize()

# Update all coordinates that define important surfaces within the mesh
eps = 1e-3
fault_final = gmsh.model.occ.getEntitiesInBoundingBox(
    -l_f / 2 - eps, -w_f - eps, -w_f - eps, l_f / 2 + eps, w_f + eps, w_f + eps, 2
)
fault_final_tags = [val[-1] for val in fault_final]
areas = []
for surface in fault_final_tags:
    areas.append(gmsh.model.occ.getMass(2, surface))
nucl_new = fault_final[areas.index(min(areas))]

top = gmsh.model.occ.getEntitiesInBoundingBox(
    x0 - eps, y0 - eps, -eps, x1 + eps, y1 + eps, eps, 2
)
others = gmsh.model.occ.getEntities(2)
others = [elem for elem in others if elem not in fault_final + top]

gmsh.model.mesh.setSize(gmsh.model.getBoundary([nucl_new], False, False, True), h_nucl)
gmsh.model.mesh.setSize(gmsh.model.getBoundary(others, False, False, True), h_domain)
gmsh.model.mesh.setSize(
    gmsh.model.getBoundary(fault_final, False, False, True), h_fault
)

gmsh.model.addPhysicalGroup(2, [val[-1] for val in top], 1)
gmsh.model.addPhysicalGroup(2, [val[-1] for val in fault_final], 3)
gmsh.model.addPhysicalGroup(2, [val[-1] for val in others], 5)
gmsh.model.addPhysicalGroup(3, [box], 1)

gmsh.model.mesh.generate(3)

gmsh.fltk.run()
gmsh.finalize()
