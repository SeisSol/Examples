/*
/**
 * @file
 * This file is part of SeisSol.
 *
 * @author Thomas Ulrich and Duo Li 
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

hbnd = 5000;
hfault1 = 50;
hfault2 = 200;
hfault3 = 150;

Point(1) = {-21000, -42000, 0, 5000};
Point(2) = {69000, -42000, 0, 5000};
Point(3) = {69000, 42000, 0, 5000};
Point(4) = {-21000, 42000, 0, 5000};
Point(5) = {-21000, -42000, -42000, 5000};
Point(6) = {69000, -42000, -42000, 5000};
Point(7) = {69000, 42000, -42000, 5000};
Point(8) = {-21000, 42000, -42000, 5000};
Point(9) = {0, 0, 0, 150};
Point(10) = {48000, 0, 0, 150};
Point(11) = {0, 0, -19500, 150};
Point(12) = {48000, 0, -19500, 150};
Point(13) = {-21000, 0, 0, 5000};
Point(14) = {-21000, 0, -42000, 5000};
Point(15) = {69000, 0, 0, 5000};
Point(16) = {69000, 0, -42000, 5000};
Point(17) = {21500, 0, -7250, 50};
Point(18) = {26500, 0, -7250, 50};
Point(19) = {26500, 0, -12250, 50};
Point(20) = {21500, 0, -12250, 50};
Point(21) = {19000, 0, -4750, 200};
Point(22) = {29000, 0, -4750, 200};
Point(23) = {29000, 0, -14750, 200};
Point(24) = {19000, 0, -14750, 200};
Line(1) = {11, 12};
Line(2) = {12, 10};
Line(3) = {10, 9};
Line(4) = {9, 11};
Line(5) = {4, 3};
Line(6) = {3, 7};
Line(7) = {7, 8};
Line(8) = {8, 4};
Line(9) = {5, 1};
Line(10) = {1, 2};
Line(11) = {2, 6};
Line(12) = {6, 5};
Line(33) = {13, 9};
Line(34) = {11, 14};
Line(35) = {14, 13};
Line(36) = {10, 15};
Line(37) = {12, 16};
Line(38) = {16, 15};
Line(39) = {15, 3};
Line(40) = {2, 15};
Line(41) = {16, 14};
Line(42) = {14, 5};
Line(43) = {1, 13};
Line(44) = {6, 16};
Line(45) = {13, 4};
Line(46) = {8, 14};
Line(47) = {16, 7};
Line(106) = {9, 21};
Line(107) = {21, 22};
Line(108) = {22, 10};
Line(109) = {22, 23};
Line(110) = {23, 12};
Line(111) = {23, 24};
Line(112) = {24, 11};
Line(113) = {24, 21};
Line(114) = {21, 17};
Line(115) = {17, 18};
Line(116) = {18, 22};
Line(117) = {18, 19};
Line(118) = {19, 23};
Line(119) = {19, 20};
Line(120) = {20, 17};
Line(121) = {20, 24};
Line Loop(18) = {8, 5, 6, 7};
Plane Surface(18) = {18};
Line Loop(24) = {12, 9, 10, 11};
Plane Surface(24) = {24};
Line Loop(49) = {45, -8, 46, 35};
Plane Surface(49) = {49};
Line Loop(51) = {42, 9, 43, -35};
Plane Surface(51) = {51};
Line Loop(53) = {42, -12, 44, 41};
Plane Surface(53) = {53};
Line Loop(55) = {41, -46, -7, -47};
Plane Surface(55) = {55};
Line Loop(57) = {47, -6, -39, -38};
Plane Surface(57) = {57};
Line Loop(59) = {38, -40, 11, 44};
Plane Surface(59) = {59};
Line Loop(63) = {37, 38, -36, -2};
Plane Surface(63) = {63};
Line Loop(65) = {34, 35, 33, 4};
Plane Surface(65) = {65};
Line Loop(67) = {5, -39, -36, 3, -33, 45};
Plane Surface(67) = {67};
Line Loop(69) = {33, -3, 36, -40, -10, 43};
Plane Surface(69) = {69};
Line Loop(123) = {106, -113, 112, -4};
Plane Surface(123) = {123};
Line Loop(125) = {106, 107, 108, 3};
Plane Surface(125) = {125};
Line Loop(127) = {109, 110, 2, -108};
Plane Surface(127) = {127};
Line Loop(129) = {110, -1, -112, -111};
Plane Surface(129) = {129};
Line Loop(131) = {111, -121, -119, 118};
Plane Surface(131) = {131};
Line Loop(133) = {117, 118, -109, -116};
Plane Surface(133) = {133};
Line Loop(135) = {116, -107, 114, 115};
Plane Surface(135) = {135};
Line Loop(137) = {114, -120, 121, 113};
Plane Surface(137) = {137};
Line Loop(139) = {120, 115, 117, 119};
Plane Surface(139) = {139};
Line Loop(140) = {41, -34, 1, 37};
Plane Surface(140) = {140};
Surface Loop(142) = {18, 49, 67, 57, 55, 140, 65, 123, 125, 135, 133, 139, 137, 131, 129, 127, 63};
Volume(142) = {142};
Surface Loop(144) = {140, 65, 123, 125, 135, 133, 139, 137, 131, 129, 127, 63, 59, 69, 24, 53, 51};
Volume(144) = {144};
Physical Surface(103) = {125, 123, 129, 127, 135, 137, 133, 131, 139};
Physical Surface(101) = {67, 69};
Physical Surface(105) = {18, 59, 57, 49, 51, 24, 53, 55};
Physical Volume(1) = {142, 144};
Mesh.MshFileVersion = 2.2;
