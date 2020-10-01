/*
/**
 * @file
 * This file is part of SeisSol.
 *
 * @author Duo Li 
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
cl = 5.0e3;
cl_fault=200;

// This file builds a rectangular box domain region which is exactly the same as topographic data.

level = 0.2e3; // vertical elevation
region = 140e3; // range in meter
depth = 60e3;

Point(1) = { 0.5*region, 0.5*region, level, cl} ; //water level
Point(2) = { -0.5*region,0.5*region, level, cl} ; 
Point(3) = { -0.5*region,-0.5*region, level, cl} ; 
Point(4) = { 0.5*region, -0.5*region, level, cl} ;

Line(1) = {1,2}; Line(2) = {2,3}; Line(3) = {3,4}; Line(4) = {4,1}; 

Point(5) = { 0.5*region, 0.5*region,-depth, cl} ; 
Point(6) = { -0.5*region,0.5*region,-depth, cl} ;
Point(7) = { -0.5*region,-0.5*region,-depth, cl} ; 
Point(8) = { 0.5*region,-0.5*region, -depth, cl} ;

Line(5) = {5,6}; Line(6) = {6,7}; Line(7) = {7,8}; Line(8) = {8,5}; 

Line(9) = {1,5}; Line(10) = {2,6}; Line(11) = {3,7}; Line(12) = {4,8};

Line Loop(1) = {  1,  2,   3,  4} ; Plane Surface(7) = {1} ;// the free surface
Line Loop(2) = {  5,  6,   7,  8} ; Plane Surface(2) = {2} ;
Line Loop(3) = {  -4, 12,  8,  -9} ; Plane Surface(3) = {3} ; //
Line Loop(4) = {  9,  5, -10,  -1} ; Plane Surface(4) = {4} ;
Line Loop(5) = { 10,  6,  -11, -2} ; Plane Surface(5) = {5} ;
Line Loop(6) = { 11,  7,  -12, -3} ; Plane Surface(6) = {6} ;

// fault surface

fwidth = 20e3;
flength = 40e3;

Point(21) = {-0.5*flength, 0, 0, cl_fault};
Point(22) = {0.5*flength, 0, 0, cl_fault};
Point(23) = {0.5*flength, 0, -fwidth, cl_fault};
Point(24) = {-0.5*flength, 0, -fwidth, cl_fault};
Line(21) = {21,22};
Line(22) = {22,23};
Line(23) = {23,24};
Line(24) = {24,21};
// Line{21} In Surface{7};

Line Loop(21) = {21,22,23,24} ;
Plane Surface(1) = {21} ; // fault face

Physical Surface(101) = {7};// free surface
Physical Surface(105) = {2,3,4,5,6};//absorb boundary
Physical Surface(103) = {1}; // dynamic rupture

Mesh.MshFileVersion = 1.0;

