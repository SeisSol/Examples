/*
/**
 * @file
 * This file is part of SeisSol.
 *
 * @author Carsten Uphoff and Duo Li
 *
 * @section LICENSE
 * Copyright (c) 2014-2015, SeisSol Group
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

 */
 
cl_1 = 5000;
Point(1) = {32000, 32000, 0, cl_1};
Point(2) = {32000, 32000, 1000, cl_1};
Point(3) = {-26000, 32000, 1000, cl_1};
Point(4) = {-26000, 32000, 0, cl_1};
Point(5) = {-26000, -26000, 0, cl_1};
Point(6) = {-26000, -26000, 1000, cl_1};
Point(7) = {32000, -26000, 1000, cl_1};
Point(8) = {32000, -26000, 0, cl_1};
Point(9) = {32000, 32000, 34000, cl_1};
Point(10) = {-26000, 32000, 34000, cl_1};
Point(11) = {32000, -26000, 34000, cl_1};
Point(12) = {-26000, -26000, 34000, cl_1};
Point(13) = {4000, 4000, 1500, cl_1};
Line(1) = {4, 5};
Line(2) = {5, 8};
Line(3) = {8, 7};
Line(4) = {7, 6};
Line(5) = {6, 5};
Line(6) = {6, 3};
Line(7) = {3, 4};
Line(8) = {4, 1};
Line(9) = {1, 8};
Line(10) = {7, 2};
Line(11) = {2, 1};
Line(12) = {2, 3};
Line(13) = {3, 10};
Line(14) = {10, 9};
Line(15) = {9, 11};
Line(16) = {11, 12};
Line(17) = {12, 6};
Line(18) = {7, 11};
Line(19) = {2, 9};
Line(20) = {10, 12};
Line Loop(22) = {20, -16, -15, -14};
Plane Surface(22) = {22};
Line Loop(24) = {13, 20, 17, 6};
Plane Surface(24) = {24};
Line Loop(26) = {17, -4, 18, 16};
Plane Surface(26) = {26};
Line Loop(28) = {19, 15, -18, 10};
Plane Surface(28) = {28};
Line Loop(30) = {12, 13, 14, -19};
Plane Surface(30) = {30};
Line Loop(32) = {12, -6, -4, 10};
Plane Surface(32) = {32};
Line Loop(34) = {5, 2, 3, 4};
Plane Surface(34) = {34};
Line Loop(36) = {3, 10, 11, 9};
Plane Surface(36) = {36};
Line Loop(38) = {6, 7, 1, -5};
Plane Surface(38) = {38};
Line Loop(40) = {7, 8, -11, 12};
Plane Surface(40) = {40};
Line Loop(42) = {8, 9, -2, -1};
Plane Surface(42) = {42};
Surface Loop(1) = {22, 24, 26, 28, 30, 32};
Volume(1) = {1};
Surface Loop(2) = {32, 34, 36, 38, 40, 42};
Volume(2) = {2};
Physical Surface(101) = {42};
Physical Surface(105) = {22, 24, 26, 28, 30, 34, 36, 38, 40};
Physical Volume(1) = {2};
Physical Volume(2) = {1};
// define refined box
Field[1] = Box;
Field[1].VIn = 200;
Field[1].VOut = 3000;
Field[1].XMax = 12000;
Field[1].XMin = -2500;
Field[1].YMax = 12000;
Field[1].YMin = -2500;
Field[1].ZMax = 6000;
Field[1].ZMin = 0;
// define distance to reference point 13
Field[2] = Distance;
Field[2].NodesList = {13};
// define radial refinement method
Field[3] = MathEval;
Field[3].F = "150 + F2^2/6000^2*100";
Field[4] = Min;
Field[4].FieldsList = {1, 3};
// final 
Background Field = 4;
// specify gmsh version 
Mesh.MshFileVersion = 2.2;
