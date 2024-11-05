/*
/**
 * @file
 * This file is part of SeisSol.
 *
 * @author Fabian Kutschera, adapted from https://github.com/SeisSol/Training/tree/main/tpv13
 *
 * @section LICENSE
 * Copyright (c) 2014-2024, SeisSol Group
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 * 
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 * 
 * 3. Neither the name of the copyright holder nor the names of its
 *    contributors may be used to endorse or promote products derived from this
 *    software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE  USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 

Creates the mesh for tpv36 and tpv37, 15 degree shallow dip thrust fault
For more information see https://strike.scec.org/cvws/tpv36_37docs.html
Obtain the mesh (gmsh 4.12.2):
gmsh -3 tpv36_37_mesh_refined.geo
Convert the mesh:
module use /import/exception-dump/ulrich/spack/modules/linux-debian12-zen2
module load pumgen
pumgen -s simmodsuite -l ../LudwigU_2024 tpv36_37_mesh_refined.msh -s msh2

 */

// Definition of the default mesh discretisation and dip of the fault. 
// The fault here is set to require smaller elements than the volume. 
// This will lead to a statically refined mesh. 
// The mesh discretisation can be changed within Min and Max values using the Gmsh GUI

DefineConstant[ h_domain = {15e3, Min 0, Max 500e3, Name "Mesh spacing within model domain" } ];

// Run these benchmarks using 50 meter resolution on the fault (note: SeisSol has higher-order)
DefineConstant[ h_fault = {200.0, Min 0, Max 30e3, Name "Mesh spacing on the fault" } ];
// The value above is also taken for the free surface.

// The fault is a planar thrust fault that dips at an angle of 15 degrees.
DefineConstant[ dip = {15, Min 0, Max 90, Name "Fault dip" } ];

// Specifies the back-end of the CAD engine
SetFactory("OpenCASCADE");

// Length of the fault
l_f = 30e3;
// Depth of the fault, i.e., down-dip width (initially vertically dipping, fault is rotated later)
w_f = 28e3;
// Fault dips towards the north
dip_rad = (180-dip)*Pi/180.;

// Domain size: see sketch (and note different coordinate axis [x,y,z] convention cf. benchmark description [x,z,y])
// Initial tests with smaller domain (may be used to decrease mesh generation time using gmsh)
//X0 = -30e3; 
//X1 = -X0;
//Y0 = -15e3;
//Y1 = 53e3;
//Z0 = -40e3;
// Larger domain size
X0 = -80e3;
X1 = -X0;
Y0 = -70e3;
Y1 = 90e3;
Z0 = -60e3;

// Create the domain as a box
domain = newv; Box(domain) = {X0, Y0, Z0, X1-X0, Y1-Y0, -Z0};

// Create the fault as a vertically dipping rectangle, centered in x at the hypocenter
fault = news; Rectangle(fault) = {-l_f/2, -w_f, 0, l_f, w_f};

// Rotate the fault, according to its dip
Rotate{ {1, 0, 0}, {0, 0, 0}, dip_rad } { Surface{fault}; }

// Intersect the domain box with the fault rectangle at the free surface
v() = BooleanFragments{ Volume{domain}; Delete; }{ Surface{fault}; Delete; };

// Update all coordinates that define important surfaces within the mesh
eps = 1e-3;
fault_final[] = Surface In BoundingBox{-l_f/2-eps, -w_f-eps, -w_f-eps, l_f/2+eps, w_f+eps, w_f+eps};
top[] = Surface In BoundingBox{X0-eps, Y0-eps, -eps, X1+eps, Y1+eps, eps};
other[] = Surface{:};
other[] -= fault_final[];
other[] -= top[];

// Set mesh spacing of the domain, the fault and the nucleation patch
MeshSize{ PointsOf{Volume{domain};} } = h_domain;
MeshSize{ PointsOf{Surface{fault_final[]};} } = h_fault;
MeshSize{ PointsOf{Surface{top[]};} } = h_fault;
// Sets same on-fault mesh spacing for free surface 

// Define boundary conditions, note the SeisSol specific meaning of 1 = free surface, 3 = dynamic rupture, 5 = absorbing boundary conditions
// free surface
Physical Surface(1) = {top[]};
// dynamic rupture
Physical Surface(3) = {fault_final[]};
// absorbing boundaries
Physical Surface(5) = {other[]};

Physical Volume(1) = {domain};
Mesh.MshFileVersion = 2.2;
