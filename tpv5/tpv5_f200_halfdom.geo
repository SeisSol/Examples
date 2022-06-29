/**
 * @file
 * This file is part of SeisSol.
 *
 * @author Duo Li & Thomas Ulrich 
 *
 * @section LICENSE
 * Copyright (c) 2014-2022, SeisSol Group
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

 Generate mirror mesh about fault plane with:

 gmsh -3 tpv5_f200_halfdom.geo
 pumgen tpv5_f200_halfdom.msh -s msh2
 python mirrorMesh.py tpv5_f200_halfdom.xdmf 1 0
*/

lc= 5000;
lc_fault = 100;

Point(1) = {-50000, 0, -50000, lc};
Point(2) = {-50000, 0, 0, lc};
Point(3) = {50000, 0, 0, lc};
Point(4) = {50000, 0, -50000, lc};
Point(100) = {-15000, 0, -15000, lc};
Point(101) = {15000, 0, -15000, lc};
Point(102) = {15000, 0, 0, lc};
Point(103) = {-15000, 0, 0, lc};
Point(200) = {0, 0, -7500, lc_fault};
Point(201) = {0, 0, -6100, lc_fault};
Point(202) = {1400, 0, -7500, lc_fault};
Point(203) = {0, 0, -8900, lc_fault};
Point(204) = {-1400, 0, -7500, lc_fault};
Point(211) = {0, 0, -5500, lc_fault};
Point(212) = {2000, 0, -7500, lc_fault};
Point(213) = {0, 0, -9500, lc_fault};
Point(214) = {-2000, 0, -7500, lc_fault};
Point(1011) = {-50000, 50000, -50000, lc};
Point(1012) = {-50000, 50000, 0, lc};
Point(1013) = {50000, 50000, 0, lc};
Point(1014) = {50000, 50000, -50000, lc};
Line(1) = {1, 2};
Line(2) = {2, 103};
Line(3) = {103, 100};
Line(4) = {100, 101};
Line(5) = {101, 102};
Line(6) = {102, 3};
Line(7) = {3, 4};
Line(8) = {4, 1};
Line(9) = {103, 102};
Circle(200) = {201, 200, 202};
Circle(201) = {202, 200, 203};
Circle(202) = {203, 200, 204};
Circle(203) = {204, 200, 201};
Circle(210) = {211, 200, 212};
Circle(211) = {212, 200, 213};
Circle(212) = {213, 200, 214};
Circle(213) = {214, 200, 211};
Line(216) = {2, 1012};
Line(218) = {3, 1013};
Line(220) = {4, 1014};
Line(222) = {1014, 1013};
Line(233) = {1011, 1};
Line(235) = {1011, 1012};
Line(236) = {1013, 1012};
Line(237) = {1011, 1014};
Line Loop(1) = {1, 2, 3, 4, 5, 6, 7, 8};
Plane Surface(1) = {1};
Line Loop(2) = {3, 4, 5, -9, 210, 211, 212, 213};
Plane Surface(2) = {2};
Line Loop(3) = {210, 211, 212, 213, 200, 201, 202, 203};
Plane Surface(3) = {3};
Line Loop(4) = {200, 201, 202, 203};
Plane Surface(4) = {4};
Line Loop(242) = {1, 216, -235, 233};
Plane Surface(242) = {242};
Line Loop(248) = {-8, 220, -237, 233};
Plane Surface(248) = {248};
Line Loop(250) = {237, 222, 236, -235};
Plane Surface(250) = {250};
Line Loop(256) = {220, 222, -218, 7};
Plane Surface(256) = {256};
Line Loop(258) = {2, 9, 6, 218, 236, -216};
Plane Surface(258) = {258};
Line Loop(10000) = {3, 4, 5, -9};
Ruled Surface(10000) = {10000};
Surface Loop(274) = {1, 2, 3, 4, 242, 248, 250, 256, 258};
Volume(274) = {274};

Field[1] = Distance;
Field[1].FacesList = {10000};
Field[1].NNodesByEdge = 20;
Field[2] = MathEval;
//Field[2].F = Sprintf("0.05*F1 +(F1/2.5e3)^2 + %g", lc_fault);
Field[2].F = Sprintf("0.1*F1 +(F1/5.0e3)^2 + %g", lc_fault);
Background Field = 2;

Physical Surface(101) = {258};
Physical Surface(105) = {242, 248, 250, 256};
Physical Surface(103) = {2, 3, 4};
Physical Volume(1) = {274};
Mesh.MshFileVersion = 2.2;
