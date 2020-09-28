! modified to fix intersection 
! D. Li 26-10-2018
!/*
!/**
 !* @file
 !* This file is part of SeisSol.
 !*
 !* @author: modified by Duo Li based on script from Gmsh community - R.H. 09/2018 
 !*
 !* @section LICENSE
 !* Copyright (c) 2014-2015, SeisSol Group
 !* All rights reserved.
 !* 
 !* Redistribution and use in source and binary forms, with or without
 !* modification, are permitted provided that the following conditions are met:
 !* 
 !* 1. Redistributions of source code must retain the above copyright notice,
 !*    this list of conditions and the following disclaimer.
 !* 
 !* 2. Redistributions in binary form must reproduce the above copyright notice,
 !*    this list of conditions and the following disclaimer in the documentation
 !*    and/or other materials provided with the distribution.
 !* 
 !* 3. Neither the name of the copyright holder nor the names of its
 !*    contributors may be used to endorse or promote products derived from this
 !*    software without specific prior written permission.
 !*
 !* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 !* AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 !!* IMPLIED WARRANTIES OF  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 !* ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 !* LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 !* CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 !* SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 !* INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 !* ARISING IN ANY WAY OUT OF THE  USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 !* POSSIBILITY OF SUCH DAMAGE.


PROGRAM interpol_topo
!---------------------------------------------------------------------------------------------   
!
   implicit none
   
!- global variables --------------------------------------------------------------------------         
   integer, parameter :: &
      MAXSURF   = 100,   & ! max. number of faces on the surface
      MAXSMOOTH = 100,   & ! max. number of faces for which a mesh smoothing is required
      MAXCN     = 100      ! max. number of node-node connections
   
   character(len=80) :: &
      SkinMeshFileIn ,  & ! the input mesh file name
      SkinMeshFileOut,  & ! the output mesh file name
      TopoFile            ! the topography file (grid) name
                                     
   integer          ::              &
      SurfaceMeshFaces (MAXSURF  ), & ! the face #(s) corresponding to the surface
      MeshFacesToSmooth(MAXSMOOTH)    ! the face #(s) where barycentric smoothing 
                                      ! will be applied if desired
!
!- For the mesh:
!
   integer      ::  &
      npoin = 0,    & ! total number of nodes on the skin mesh 
      nobj  = 0,    & ! total number of elementary objects
      nelm  = 0,    & ! total number of elements (tri and quad) on the skin
      nnod  = 0       ! max. number of nodes by object
   
   real(kind=8), allocatable :: &
      coordmesh(:,:)  ! mesh nodes coordinates

   integer, allocatable :: &
      iobj   (:  ),        & ! object #s
      itypo  (:  ),        & ! object types
      iregp  (:  ),        & ! physical tag region #s
      irego  (:  ),        & ! elementary tag #s
      inode  (:  ),        & ! nodes #s
      nnode  (:  ),        & ! number of nodes for each object
      meshobj(:,:),        & ! element connectivities
      mark   (:  )           ! work array
!
!- For the topography grid:
!
   integer   ::  &
      nx = 0,    & ! number of x-values on the grid
      ny = 0       ! number of y-values on the grid
   
   real(kind=8), allocatable :: &
      xtopo(:  ),               & ! x-topography grid
      ytopo(:  ),               & ! y-topography grid
      ztopo(:,:)                  ! topography values
!
!- For the smoothing algotithm:
!
   integer      :: IterMaxSmooth = 0
   real(kind=8) :: TolerSmooth   = 0.0e0_8    
!
!- Merge the data in a namelist:
! 
   namelist / input /  SkinMeshFileIn   , &  
                       SkinMeshFileOut  , &  
                       TopoFile         , &  
                       SurfaceMeshFaces , &  
                       MeshFacesToSmooth, &
                       IterMaxSmooth    , &
                       TolerSmooth
!---------------------------------------------------------------------------------------------   
                            
!
!- Read the data (namelist "input") on the input file 'interpol_topo.in':
!   
   call ReadNameList ()
!
!- Read the mesh of the skin on the file given by "SkinMeshFileIn":
!   
   call ReadGmshv1 ()
!
!- Read the topography on the file given by "TopoFile":
!
   call ReadTopography ()
!
!- Interpolate the topography on the faces # given in "SurfaceMeshFaces(:)" and move their nodes:
!
   call MoveNodes () 
!
!- If desired, smooth the mesh of the faces # given in "MeshFacesToSmooth":     
!
   call SmoothMesh ()
!
!- Write the modified mesh on the file given by "SkinMeshFileOut":
!
   call WriteGmshv1()

CONTAINS


!=============================================================================================
   SUBROUTINE ReadNameList
!=============================================================================================

!---------------------------------------------------------------------------------------------   
!  Reads the namelist "input" on the file 'interpol_topo.in'
!---------------------------------------------------------------------------------------------   

!- local variables ---------------------------------------------------------------------------      
   character(len=80) :: InputNameFile
!---------------------------------------------------------------------------------------------   

   if (iargc() == 0) then
      write(*,'(/,a,/)')'usage: interpol_topo InputFileName'
      stop
   end if   
   
   call getarg(1,InputNameFile)
   
   open(1,file=InputNameFile)
   read(1,nml=input)
   close(1)
   
   END SUBROUTINE ReadNameList
   

!=============================================================================================
   SUBROUTINE ReadGmshv1
!=============================================================================================

!---------------------------------------------------------------------------------------------   
!  Reads a mesh on the file "SkinMeshFileIn" (gmsh .msh file in format version 1) 
!---------------------------------------------------------------------------------------------   

!- local variables ---------------------------------------------------------------------------      
   character(len=80)              :: line
   character(len=3000)            :: msg
   integer                        :: err, i, j, numf  
!---------------------------------------------------------------------------------------------   

   open (unit   = 1     , file   = SkinMeshFileIn, status = 'old',  &
         action = 'read', iostat = err           , iomsg  = msg  )

   
   nelm = 0 ; nnod = 0

   do
      read(1,'(a)',iostat=err,iomsg=msg) line ; if (err /= 0) exit
      line = adjustl(line)
      
      if (line == "$NOD") then
         read(1,*,iostat=err,iomsg=msg) npoin ; if (err /= 0) exit
         
         allocate(coordmesh(3,npoin),inode(npoin))
         allocate(mark(npoin), source = 0)
      
         do i = 1, npoin
            read(1,*,iostat=err,iomsg=msg) inode(i),coordmesh(1:3,inode(i)) ; if (err /= 0) exit
         end do
         
         if (err /= 0) exit
     
      else if (line == "$ELM") then
         read(1,*,iostat=err,iomsg=msg) nobj ; if (err /= 0) exit

         allocate(iobj(nobj), itypo(nobj), iregp(nobj), irego(nobj), &
                  nnode(nobj), meshobj(30,nobj))

         do i = 1, nobj
            read(1,*,iostat=err,iomsg=msg) iobj(i),itypo(i),iregp(i),irego(i), &
                                           nnode(i),meshobj(1:nnode(i),i)
            if (err /= 0) exit 

            if (itypo(i) ==  2 .or. itypo(i) ==  3 .or. itypo(i) == 9 .or. &
                itypo(i) == 10 .or. itypo(i) == 16                         ) then ! tri or quad
                nelm = nelm + 1
                nnod = max(nnod,nnode(i))
!                
!-             tag the nodes (mark(i)=1) that belong on the surface: 
!
               do j = 1, MAXSURF
                  numf = SurfaceMeshFaces(j)
                  if (numf == 0) exit
                  if (numf == irego(i)) then
                     mark(meshobj(1:nnode(i),i)) = 1
                  end if
               end do          
            end if

         end do 
         
         if (err /= 0) exit  
      
      end if   
   end do      
   
   close(unit = 1)
   
   if (err > 0) then
      write(*,'(a,/,a)')'Error in ReadGmsh:',trim(msg)
      stop
   end if
       
   END SUBROUTINE ReadGmshv1
   

!=============================================================================================
   SUBROUTINE ReadTopography
!=============================================================================================

!---------------------------------------------------------------------------------------------   
!  Reads the topography (on a structured grid) on the file "TopoFile"
!---------------------------------------------------------------------------------------------   

!- local variables ---------------------------------------------------------------------------      
   integer             :: err, i
   character(len=3000) :: msg
!---------------------------------------------------------------------------------------------   

   open (unit   = 1    , file   = TopoFile, status = 'old',  &
         action = 'read', iostat = err   , iomsg  = msg)
   
   if (err /= 0) then
      write(*,'(a,/,a)')'Error in ReadTopo:',trim(msg)
      stop
   end if   
   
   read(1,*,iostat=err,iomsg=msg) nx,ny
   if (err /= 0) then
      write(*,'(a,/,a)')'Error in ReadTopo:',trim(msg)
      stop
   end if      

   allocate(xtopo(nx), ytopo(ny), ztopo(nx,ny), stat = err)
   if (err /= 0) then
      write(*,'(a,/,a)')'Error in ReadTopo during allocation of xtopo, ytopo or ztopo'
      stop
   end if   
   
   read(1,*,iostat=err,iomsg=msg) xtopo(1:nx)
   write(*,*) xtopo(1:nx)
   if (err /= 0) then
      write(*,'(a,/,a)')'Error in ReadTopo:',trim(msg)
      stop
   end if       
   
   read(1,*,iostat=err,iomsg=msg) ytopo(1:ny)
   ytopo(1:ny) = -ytopo(1:ny)

   if (err /= 0) then
      write(*,'(a,/,a)')'Error in ReadTopo:',trim(msg)
      stop
   end if       
   
   do i = 1, ny
      read(1,*,iostat=err,iomsg=msg) ztopo(1:nx,i)
      if (err /= 0) then
         write(*,'(a,/,a)')'Error in ReadTopo:',trim(msg)
         stop   
      end if   
   end do
   
   close(unit = 1)

   END SUBROUTINE ReadTopography
   

!=============================================================================================
   SUBROUTINE MoveNodes
!=============================================================================================

!---------------------------------------------------------------------------------------------   
!  Interpolates the topography on the faces # SurfaceMeshFaces(:) and moves correspondingly
!  their nodes 
!---------------------------------------------------------------------------------------------   

!- local variables ---------------------------------------------------------------------------      
   integer :: i, in, ix, iy
   real(kind=8) :: x, y, dx, dy, exi, eta, s1, s2, t1, t2, sh1, sh2, sh3, sh4, h_i
!---------------------------------------------------------------------------------------------   
   
!
!- Move verticaly each node #i of the surface (node marked by mark(i) = 1) by an amount h_i
!  computed by interpolation of the topography at this node
!
   do i = 1, npoin
      in = inode(i)
      if (mark(in) == 0) cycle
!
!-    horizontal coordinates of this node:
!      
      x = coordmesh(1,in) ; y = -coordmesh(3,in)
!
!-    localize this nodes on the topography grid:
!      
      ix = FindInterval (xtopo, x) ; iy = FindInterval (ytopo, y)
      write(*,*) ix,iy
!
!-    cycle, if outside the grid:
!
      if (ix == 0 .or. iy == 0) cycle
!
!-    else, perform a Q1 interpolation (h_i) of ztopo:
!
      dx = xtopo(ix+1) - xtopo(ix)
      dy = ytopo(iy+1) - ytopo(iy)
      exi = 2.0e0*((x - xtopo(ix))/dx) - 1.0e0
      eta = 2.0e0*((y - ytopo(iy))/dy) - 1.0e0
      s1 = 1.0e0 - exi ; s2 = 1.0e0 + exi
      t1 = 1.0e0 - eta ; t2 = 1.0e0 + eta
      sh1 = s1*t1 ; sh2 = s2*t1 ; sh3 = s2*t2 ; sh4 = s1*t2
      h_i = (ztopo(ix  ,iy  )*sh1 + ztopo(ix+1,iy  )*sh2 +      &
             ztopo(ix+1,iy+1)*sh3 + ztopo(ix  ,iy+1)*sh4 )*0.25
      write(*,*) h_i
!
!-    move this node (choose if  z_new = h_i  or if  z_new = z_old + h_i)
!             
      !coordmesh(3,in) = coordmesh(3,in) + h_i
      coordmesh(2,in) =  h_i
   end do
   
   END SUBROUTINE MoveNodes


!=============================================================================================
   SUBROUTINE SmoothMesh
!=============================================================================================

!---------------------------------------------------------------------------------------------   
!  Smooths the mesh of the faces # MeshFacesToSmooth(:) by a barycentric procedure
!---------------------------------------------------------------------------------------------   

!- local variables ---------------------------------------------------------------------------  
   integer     , parameter   :: NITERMAX_default = 200 
   real(kind=8), parameter   :: TOLER_default = 1e-2_8
   integer                   :: i, j, ip, jp, iv, iter, n, nve, nvp, numf, nelem, nitermax
   integer     , allocatable :: lnods(:,:), lvale(:), lvois(:,:)
   real(kind=8)              :: dep, dep1, u(3), v(3), toler
   logical                   :: conv
   character(len=99)         :: cnum
!---------------------------------------------------------------------------------------------   

   nitermax = IterMaxSmooth
   toler    = TolerSmooth
   
   if (nitermax == 0      ) nitermax = NITERMAX_default
   if (toler    == 0.0e0_8) toler    = TOLER_default
   
   allocate(lnods(nnod,nelm), source=0)
!
!- scroll through the faces to smooth:
! 
   do j = 1, MAXSMOOTH
      numf = MeshFacesToSmooth(j)
      if (numf == 0) exit
!
!-    extract the connectivity (lnods) of this face and tag (mark(i)=1) its nodes:
!
      nelem = 0
      mark = 0

      do i = 1, nobj
         if (itypo(i) ==  2 .or. itypo(i) ==  3 .or. itypo(i) == 9 .or. &
             itypo(i) == 10 .or. itypo(i) == 16                         ) then ! tri or quad
            if (irego(i) == numf) then
               nelem = nelem + 1 
               lnods(1:nnode(i),nelem) = meshobj(1:nnode(i),i)
               mark(meshobj(1:nnode(i),i)) = 1
            end if
         end if
      end do
!
!-    compute neighbourhood tables:
!      
      call Neighbourhood (lnods, nnod, nelem, lvale, lvois)  
!
!-    apply in-plane barycentric smoothing (in nitermax iterations):
!      
      conv = .false.
      
      do iter = 1, nitermax
         dep = 0.0e0_8
         n = 0
         do ip = 1, npoin
            if (mark(ip) == 0) cycle
            nve = lvale(ip) ; nvp = lvois(MAXCN,ip)
            if (nve /= nvp) cycle ! do not perturb boundary nodes
            u = coordmesh(1:3,ip)
            coordmesh(1:3,ip) = 0.0e0_8
            do iv = 1, nvp
               jp = lvois(iv,ip)
               coordmesh(1:3,ip) = coordmesh(1:3,ip) + coordmesh(1:3,jp)
            end do
            coordmesh(1:3,ip) = coordmesh(1:3,ip) / real(nvp,kind=8)
            v = coordmesh(1:3,ip) - u
            n = n + 1
            dep = dep + v(1)**2 + v(2)**2 + v(3)**2
         end do
         dep = sqrt(dep) / real(n,kind=8)
         
         if (iter == 1) then
            dep1 = dep
         else
            if (dep < toler*dep1) then
               conv = .true. ; exit
            end if   
         end if      
      end do               
      
      if (.not. conv) then
         write(cnum,'(f12.5)')dep/dep1
         write(*,'(a,i0,a,i0,a)')                                              &
            'In SmoothMesh: smoothing for face #',numf,' NOT converged in ',   &
            nitermax, ' iterations (dep/dep1 = '//trim(adjustl(cnum))//')'      
      else
         write(*,'(a,i0,a,i0,a)')                                             &
            'In SmoothMesh: smoothing for face #',numf,' converged in ',iter, &
            ' iterations'      
      end if      
   end do  

   END SUBROUTINE SmoothMesh


!=============================================================================================
   SUBROUTINE WriteGmshv1
!=============================================================================================

!---------------------------------------------------------------------------------------------   
!  Writes a mesh in gmsh .msh file format version 1
!---------------------------------------------------------------------------------------------   

!- local variables ---------------------------------------------------------------------------   
   integer             :: i, err
   character(len=3000) :: msg
!---------------------------------------------------------------------------------------------   

   open (unit   = 1      , file   = SkinMeshFileOut, status = 'replace',  &
         action = 'write', iostat = err            , iomsg  = msg      )

   if (err /= 0) then
      write(*,'(a,/,a)')'Error in WriteGmsh:',trim(msg)
      stop
   end if   

   write(1,'(a)')'$NOD'
   write(1,*)npoin
   do i = 1, npoin
      write(1,'(i0,1x,3e13.5)')inode(i), coordmesh(1:3,inode(i))
   end do

   write(1,'(a)')'$ENDNOD'
   write(1,'(a)')'$ELM'
   write(1,*)nobj
   do i = 1, nobj
      write(1,'(*(i0,1x))')iobj(i),itypo(i),iregp(i),irego(i),nnode(i),meshobj(1:nnode(i),i)
   end do   
   write(1,'(a)')'$ENDELM'
   
   close(unit = 1)

   END SUBROUTINE WriteGmshv1
   
      
!=============================================================================================
   FUNCTION FindInterval ( x, x0 ) result(ig)
!=============================================================================================   
   real(kind=8), intent(in) :: x(:), x0
   integer                  :: ig
!---------------------------------------------------------------------------------------------   
!  Finds the interval [x(ig), x(ig+1)] in which x0 is located
!  (returns 0 if x0 is outside [x(1), x(n)]
!  Warning: x(i) must be in increasing order 
!---------------------------------------------------------------------------------------------   

!- local variables ---------------------------------------------------------------------------      
   integer :: n, id, im
!---------------------------------------------------------------------------------------------   
      
   n = size(x)
   if (x0 < x(1) .or. x0 > x(n)) then
      ig = 0      ! x0 is outside 
      return
   end if

   ig = 1 ; id = n
   do while (id-ig > 1) 
      im = (ig + id) / 2
      if (x(ig) <= x0 .and. x0 < x(im)) then
         id = im
      else   
         ig = im
      end if
   end do

   END FUNCTION FindInterval                


!=============================================================================================         
   SUBROUTINE Neighbourhood ( lnods, nnode, nelem, lvale, lvois )
!=============================================================================================      
   integer,              intent(in    ) :: lnods(:,:), nelem, nnode
   integer, allocatable, intent(   out) :: lvale(:), lvois(:,:)
!---------------------------------------------------------------------------------------------   
!  Computes the neighbourhood tables lvale, lvois (node-nodes connectivities)
!---------------------------------------------------------------------------------------------   

!- local variables --------------------------------------------------------------------------         
   integer              :: i, ie, in, ip, jp, kp, kvp, nve, nvp, ideja
   integer, allocatable :: lelem(:,:)
!---------------------------------------------------------------------------------------------   
   
   allocate(lvale(      npoin), source = 0)
   allocate(lvois(MAXCN,npoin), source = 0)
   allocate(lelem(MAXCN,npoin), source = 0)

!
!- build lelem (node-elements connectivities) and lvale (number of connections):
!    
   do ie = 1, nelem
!
!-    store ie into the list of elements attached to the nodes # lnods(:,ie)      
!
      do in = 1, nnode
         ip  = lnods(in,ie)
         nve = lvale(ip) + 1
         lvale(    ip) = nve   
         lelem(nve,ip) = ie   
      end do
   end do
!
!- build lvois (node-nodes connectvities):
!	
   do ip = 1, npoin
!
!-    scroll through the elements attached to ip and find the nodes connected to ip
!
      if (mark(ip) == 0) cycle
      nvp = 0       
      nve = lvale(ip)      
      do i = 1, nve 
         ie = lelem(i,ip)
         do in = 1, nnode
            jp = lnods(in,ie)
            if (jp == ip) cycle
            ideja = 0  
            do kvp = 1, nvp
               kp = lvois(kvp,ip)
               if (kp == jp) then
                  ideja = 1 ! already stored
                  exit
               end if   
            end do
            if (ideja == 1) cycle ! already stored: next one
            nvp = nvp + 1
            if (nvp .gt. maxcn) stop 'nvp > maxcn'
            lvois(nvp,ip) = jp
         end do
      end do
      lvois(MAXCN,ip) = nvp ! total number of nodes attached to ip
   end do
   
   END SUBROUTINE Neighbourhood
   
END PROGRAM interpol_topo
