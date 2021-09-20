/*
/**
 * @file
 * This file is part of SeisSol.
 *
 * @author Duo Li and Thomas Ulrich
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

lc = 5e3;
lc_fault = 500;

faultlength = 20e3;
faultwidth = 25e3 ;
region = 200e3 ;
depth = 60e3;
dip = 52*Pi/180;
stk = (122-90)*Pi/180;

Point(1) = {0.5*faultlength*Cos(stk),  -0.5*faultlength*Sin(stk), -5e3, lc_fault};
Point(4) = {-0.5*faultlength*Cos(stk), 0.5*faultlength*Sin(stk), -5e3, lc_fault};
Point(5) = {-0.5*faultlength*Cos(stk)-faultwidth*Sin(dip)*Sin(stk), 0.5*faultlength*Sin(stk)-faultwidth*Cos(stk)*Sin(dip), -(5e3+1*faultwidth)*Cos(dip), lc_fault};
Point(6) = {0.5*faultlength*Cos(stk)-faultwidth*Sin(dip)*Sin(stk), -0.5*faultlength*Sin(stk)-faultwidth*Cos(stk)*Sin(dip),  -(5e3+1*faultwidth)*Cos(dip), lc_fault};

Point(7) = {0.5*region, 0.5*region, -depth, lc};
Point(8) = {0.5*region, -0.5*region, -depth, lc};
Point(9) = {-0.5*region, -0.5*region, -depth, lc};
Point(10) = {-0.5*region, 0.5*region, -depth, lc};
Point(11) = {-0.5*region, 0.5*region, 0, lc};
Point(13) = {0.5*region, 0.5*region, 0, lc};
Point(14) = {0.5*region, -0.5*region, 0, lc};
Point(15) = {-0.5*region, -0.5*region, 0, lc};
Line(1) = {4, 5};
Line(2) = {5, 6};
Line(3) = {6, 1};
Line(4) = {1, 4};
Line(7) = {7, 8};
Line(8) = {8, 9};
Line(9) = {9, 10};
Line(10) = {10, 7};
Line(11) = {7, 13};
Line(12) = {13, 14};
Line(13) = {14, 15};
Line(14) = {15, 9};
Line(15) = {15, 11};
Line(16) = {11, 10};
Line(17) = {11, 13};
Line(18) = {8, 14};
Line Loop(6) = {4, 1, 2, 3};
Ruled Surface(6) = {6};
Line Loop(20) = {8, 9, 10, 7};
Plane Surface(20) = {20};
Line Loop(22) = {9, -16, -15, 14};
Plane Surface(22) = {22};
Line Loop(24) = {10, 11, -17, 16};
Plane Surface(24) = {24};
Line Loop(26) = {7, 18, -12, -11};
Plane Surface(26) = {26};
Line Loop(28) = {8, -14, -13, -18};
Plane Surface(28) = {28};
Line Loop(30) = {13, 15, 17, 12};
Plane Surface(30) = {30};
//Line{4} In Suface{30};
Surface Loop(32) = {26, 20, 28, 22, 24, 30};
Volume(32) = {32};
Surface{6} In Volume{32};

Field[1] = Distance;
Field[1].FacesList = {6};
Field[1].FieldX = -1;
Field[1].FieldY = -1;
Field[1].FieldZ = -1;
Field[1].NNodesByEdge = 20;
Field[2] = MathEval;
Field[2].F = Sprintf("0.1*F1 +(F1/5000)^2 + %g", lc_fault);
Background Field = 2;

Physical Surface(101) = {30};
Physical Surface(105) = {20, 22, 24, 26, 28};
// Physical Surface(103) = {6};
Physical Volume(32) = {32};
Mesh.MshFileVersion = 2.2;
