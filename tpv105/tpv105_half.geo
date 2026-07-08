// ==========================================================
// CONSTANTS & MESH SPACING PARAMETERS
// ==========================================================
DefineConstant[ h_domain = {5000.0, Min 0, Max 50000.0, Name "Mesh spacing within domain" } ];
DefineConstant[ h_fault  = {200.0, Min 0, Max 5000.0,  Name "Mesh spacing on fault layers" } ];
DefineConstant[ h_nucl   = {200.0,  Min 0, Max 1000.0,  Name "Mesh spacing within nucleation patch" } ];

// Specifying the CAD engine backend
SetFactory("OpenCASCADE");

lbox = 60e3;
split_depth = -7.5e3; // 7.5 km depth

// ==========================================================
// GEOMETRY GENERATION
// ==========================================================

// 1. Domain box: Centered in x [-lbox, lbox], extending [0, lbox] in y, and [-lbox, 0] in z
domain = newv; 
Box(domain) = {-lbox, 0, -lbox, 2*lbox, lbox, lbox};

// 2. Horizontal cutting plane at Z = -7.5 km
cutting_plane = news;
Rectangle(cutting_plane) = {-lbox, 0, split_depth, 2*lbox, lbox};

// 3. Fault plane rectangles (Initially defined on the XY plane, to be rotated to XZ)
fault_outer = news;      Rectangle(fault_outer)      = {-22e3, -22e3, 0, 44e3, 22e3}; 
fault_mid   = news;      Rectangle(fault_mid)        = {-18e3, -18e3, 0, 36e3, 18e3}; 
fault_deep_in = news;    Rectangle(fault_deep_in)    = {-15e3, -15e3, 0, 30e3, 12e3}; 
fault_shallow_in = news; Rectangle(fault_shallow_in) = {-15e3, -3e3,  0, 30e3, 3e3};  

// 4. Nucleation Disk (Radius 1.5e3, centered at x=-4e3, y=-7.5e3 on the XY plane)
nucl = news; 
Disk(nucl) = {-4e3, -7.5e3, 0, 1.5e3};

// ==========================================================
// ROTATION (Aligning XY-plane to XZ-plane / Y=0)
// ==========================================================
Rotate { {1, 0, 0}, {0, 0, 0}, Pi/2 } { 
  Surface{fault_outer, fault_mid, fault_shallow_in, fault_deep_in, nucl}; 
}

// ==========================================================
// BOOLEAN FRAGMENTS (Resolve Intersections & Partitioning)
// ==========================================================
// Including 'cutting_plane' here splits both the domain volume and the faults at Z = -7.5 km
v() = BooleanFragments{ 
  Volume{domain}; Delete; 
}{ 
  Surface{fault_outer, fault_mid, fault_shallow_in, fault_deep_in, nucl, cutting_plane}; Delete; 
};

// ==========================================================
// SURFACE AND BOUNDARY SELECTION VIA BOUNDING BOXES
// ==========================================================
eps = 1.0;

// Gather all fault surfaces lying precisely on the Y=0 plane
fault_surfaces[] = Surface In BoundingBox{-22e3-eps, -eps, -22e3-eps, 22e3+eps, eps, eps};

// Gather the nucleation patch surface specifically
nucl_final[] = Surface In BoundingBox{-4e3-1.5e3-eps, -eps, split_depth-1.5e3-eps, -4e3+1.5e3+eps, eps, split_depth+1.5e3+eps};

// Top domain surface (Z=0)
top[] = Surface In BoundingBox{-lbox-eps, -eps, -eps, lbox+eps, lbox+eps, eps};

// Explicitly target external boundary faces to avoid selecting the internal horizontal cutting interface
bottom[] = Surface In BoundingBox{-lbox-eps, -eps, -lbox-eps, lbox+eps, lbox+eps, -lbox+eps};
left[]   = Surface In BoundingBox{-lbox-eps, -eps, -lbox-eps, -lbox+eps, lbox+eps, eps};
right[]  = Surface In BoundingBox{lbox-eps, -eps, -lbox-eps, lbox+eps, lbox+eps, eps};
back[]   = Surface In BoundingBox{-lbox-eps, lbox-eps, -lbox-eps, lbox+eps, lbox+eps, eps};

absorbing[] = {bottom[], left[], right[], back[]};

// ==========================================================
// VOLUME SELECTION
// ==========================================================
// Select the newly split volumes (above and below Z = -7.5 km)
vol_top[]    = Volume In BoundingBox{-lbox-eps, -eps, split_depth-eps, lbox+eps, lbox+eps, eps};
vol_bottom[] = Volume In BoundingBox{-lbox-eps, -eps, -lbox-eps, lbox+eps, lbox+eps, split_depth+eps};

// ==========================================================
// MESH SIZE SPECIFICATIONS
// ==========================================================
MeshSize{ PointsOf{Volume{vol_top[], vol_bottom[]};} } = h_domain;
MeshSize{ PointsOf{Surface{fault_surfaces[]};} } = h_fault;
MeshSize{ PointsOf{Surface{nucl_final[]};} } = h_nucl;


// ==========================================================
// MESH GRADIENT FIELD (Coarsening away from the fault)
// ==========================================================

// Define a distance field relative to all dynamically found fault sections
Field[1] = Distance;
Field[1].SurfacesList = {fault_surfaces[]};
Field[1].Sampling = 50; // Controls calculation sampling resolution along edges

// Apply scaling function using the distance value from Field[1] (F1)
Field[2] = MathEval;
Field[2].F = Sprintf("0.1*F1 + (F1/5.0e3)^2 + %g", h_nucl);

// Set Field 2 as the global background mesh constraint
Background Field = 2;


// ==========================================================
// SEISSOL PHYSICAL GROUPS
// ==========================================================

// 101: Free Surface (Top domain face)
Physical Surface(101) = {top[]};

// 103: Fault Plane (All fault portions including nucleation patch)
Physical Surface(103) = {fault_surfaces[]};

// 105: Absorbing Boundaries
Physical Surface(105) = {absorbing[]};

// 3D Domain Volumes (Assigned to physical tag 2 for SeisSol)
Physical Volume(2) = {vol_top[], vol_bottom[]};

Mesh.MshFileVersion = 2.2;
