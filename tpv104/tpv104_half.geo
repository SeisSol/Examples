// Gmsh project created on Tue Sep 24 15:57:06 2019

lc = 5000;
lc_fault = 200;
Point(1) = {-18e3, 0, -15e3, lc};
Point(2) = {18e3, 0, -15e3, lc};
Point(3) = {-15e3, 0, -15e3, lc};
Point(4) = {15e3, 0, -15e3, lc};
Point(5) = {15e3, 0, 0, lc};
Point(6) = {-15e3, 0, 0, lc};
Point(7) = {-18e3, 0, 0, lc};
Point(8) = {18e3, 0, 0, lc};
Point(9) = {18e3, 0, -18e3, lc};
Point(10) = {-18e3, 0, -18e3, lc};
Point(11) = {-55e3, 0, 0, lc};
Point(12) = {55e3, 0, 0, lc};
Point(13) = {55e3, 55e3, 0, lc};
Point(14) = {-55e3, 55e3, 0, lc};

Line(1) = {6, 5};
Line(2) = {4, 3};
Line(3) = {5, 4};
Line(4) = {5, 8};
Line(5) = {8, 2};
Line(6) = {2, 9};
Line(7) = {9, 10};
Line(8) = {10, 1};
Line(9) = {1, 3};
Line(10) = {4, 2};
Line(11) = {3, 6};
Line(12) = {1, 7};
Line(13) = {7, 6};
Line(14) = {7, 11};
Line(15) = {11, 14};
Line(16) = {14, 13};
Line(17) = {13, 12};
Line(18) = {12, 8};

Point(15) = {-55e3, 55e3, -55e3, lc};
Point(16) = {55e3, 55e3, -55e3, lc};
Point(17) = {55e3, 0, -55e3, lc};
Point(18) = {-55e3, 0, -55e3, lc};

Line(19) = {11, 18};
Line(20) = {18, 15};
Line(21) = {15, 14};
Line(22) = {12, 17};
Line(23) = {17, 18};
Line(24) = {16, 17};
Line(25) = {16, 13};
Line(26) = {16, 15};

Line Loop(27) = {19, -23, -22, 18, 5, 6, 7, 8, 12, 14};
Plane Surface(28) = {27};
Line Loop(29) = {9, -2, 10, 6, 7, 8};
Plane Surface(30) = {29};
Line Loop(31) = {12, 13, -11, -9};
Plane Surface(32) = {31};
Line Loop(33) = {11, 1, 3, 2};
Plane Surface(34) = {33};
Line Loop(35) = {4, 5, -10, -3};
Plane Surface(36) = {35};
Line Loop(37) = {15, -21, -20, -19};
Plane Surface(38) = {37};
Line Loop(39) = {26, 21, 16, -25};
Plane Surface(40) = {39};
Line Loop(41) = {17, 18, -4, -1, -13, 14, 15, 16};
Plane Surface(42) = {41};
Line Loop(43) = {20, -26, 24, 23};
Plane Surface(44) = {43};
Line Loop(45) = {22, -24, 25, 17};
Plane Surface(46) = {45};
Surface Loop(47) = {38, 42, 46, 28, 44, 40, 36, 30, 32, 34};

Volume(48) = {47};

//Distance only works with Ruled surface!
Line(1000) = {7, 10};
Line(1001) = {10, 9};
Line(1002) = {9, 8};
Line(1003) = {8, 7};
Line Loop(1000) = {1000,1001,1002,1003};
Ruled Surface(1000) = {1000};

Field[1] = Distance;
Field[1].FacesList = {1000};
Field[1].NNodesByEdge = 20;
Field[2] = MathEval;
Field[2].F = Sprintf("0.1*F1 +(F1/5.0e3)^2 + %g", lc_fault);
Background Field = 2;

Physical Surface(105) = {38, 44, 46, 40};
Physical Surface(101) = {42};
Physical Surface(103) = {30,34,36,32};
Physical Volume(2) = {48};

Mesh.MshFileVersion = 2.2;
