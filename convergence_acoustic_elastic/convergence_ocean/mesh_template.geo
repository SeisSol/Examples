// See: http://onelab.info/pipermail/gmsh/2016/010305.html

lc = 1000;

// example of a purely hexahedral mesh using only transfinite
// mesh constraints

Xmin = 0;
Ymin = 0;
Zmax = 0;
Zmin = -1;
Xmax = 10;
Ymax = 10;


Point(1) = {Xmin,Ymin,Zmin,lc};
Point(2) = {Xmax,Ymin,Zmin,lc};
Point(3) = {Xmax,Ymax,Zmin,lc};
Point(4) = {Xmin,Ymax,Zmin,lc};
Point(5) = {Xmin,Ymin,Zmax,lc};
Point(6) = {Xmax,Ymin,Zmax,lc};
Point(7) = {Xmax,Ymax,Zmax,lc};
Point(8) = {Xmin,Ymax,Zmax,lc};
Line(1) = {4,3};
Line(2) = {3,2};
Line(3) = {2,1};
Line(4) = {1,4};
Line(6) = {5,6};
Line(7) = {6,7};
Line(8) = {7,8};
Line(9) = {8,5};
Line(10) = {1,5};
Line(11) = {4,8};
Line(12) = {2,6};
Line(13) = {3,7};
Line Loop(14) = {3,4,1,2};
Plane Surface(15) = {14};
Line Loop(16) = {6,7,8,9};
Plane Surface(17) = {16};
Line Loop(18) = {10,-9,-11,-4};
Plane Surface(19) = {18};
Line Loop(20) = {8,-11,1,13};
Plane Surface(21) = {20};
Line Loop(22) = {12,7,-13,2};
Plane Surface(23) = {22};
Line Loop(24) = {6,-12,3,10};
Plane Surface(25) = {24};
Surface Loop(1) = {17,-25,-23,-21,19,15};
Volume(1) = {1};
Transfinite Line{1:13} = 10*${factor} + 1; // z axis
Transfinite Line{10,11,12,13} = 1*${factor} + 1; // other lines

// need to specify orientation (through vertex list) by hand to have correctly
// matching volume/surface edges
Transfinite Surface {15} = {1,2,3,4};
Transfinite Surface {17} = {5,6,7,8};
Transfinite Surface {19} = {1,5,8,4};
Transfinite Surface {21} = {4,8,7,3};
Transfinite Surface {23} = {2,6,7,3};
Transfinite Surface {25} = {1,5,6,2};
Transfinite Volume{1} = {1,2,3,4,5,6,7,8};

// 6 = periodic, 7 = analytical

Physical Surface(1) = {19,21,23,25};
Physical Surface(2) = {17};
Physical Surface(4) = {15};
//Physical Surface(8) = {19, 21, 23, 25, 17, 15,17};
Physical Volume(1) = {1};
