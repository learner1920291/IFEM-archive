.SUFFIXES: .f90
LIBS    = /usr/lib64/liblapack.so \
	  /usr/lib64/libblas.so
OBJ= global_constants.o global_simulation_parameter.o run_variables.o \
r_common.o fluid_variables.o solid_variables.o mpi_variables.o\
interface_variables.o denmesh_variables.o allocate_variables.o\
delta_nonuniform.o \
ensight_output.o form.o \
meshgen_solid.o meshgen_fluid.o meshgen_interface.o\
read.o parseinput.o correct.o  echoinput.o equal.o error.o \
facemap.o gaussj.o gjinv.o hg.o hypo.o initialize.o length.o main.o \
nondimension.o norm.o quad3d4n.o quad3d8n.o quad2d3n.o quad2d4n.o \
r_bdpd_curr.o r_bdpd_init.o r_element.o r_sbpress.o r_jacob.o r_load.o \
r_nodalf.o r_sboc.o r_scal.o r_scauchy.o r_smaterj.o  r_spiola.o \
r_spiola_viscous.o r_spiola_elastic.o r_spress.o r_sreadinit.o r_sstif.o \
r_sstrain.o r_stang.o r_stoxc.o r_timefun.o rkpmshape2d.o rkpmshape3d.o \
set.o shape.o solid_solver.o solid_update.o update.o vol.o \
data_exchange_FEM.o getinf_el_3d.o determinant.o inverse.o search_3d.o \
migs.o search_inf.o shx_tets.o energy_solid.o energy_fluid.o volcorr.o \
cg.o mergefinf.o readpart.o setnqloc.o search_inf_pa.o getinf_el_3d_pa.o \
edgeele.o nature_pre.o \
givens.o \
communicate_res.o getnorm_pa.o equal_pa.o vector_dot_pa.o \
blockdiagstable.o gmresnew.o blockgmresnew.o \
setnei_new.o communicate_res_ad.o setid_pa.o \
scale_shift_inter.o get_submesh_info.o search_inf_pa_den.o find_domain_pa.o\
search_inf_pa_inter.o get_inter_ele.o block_Laplace.o blockgmres_Laplace.o \
gmres_Laplace.o indicator_denmesh.o set_center_indicator.o get_correction_nu.o\
B_Spline.o get_normal_curvature.o get_curv_num.o get_indicator_derivative_nu.o\
B_Spline_0order.o B_Spline_1order.o B_Spline_2order.o points_regen.o \
get_fluid_property.o get_inter_vel_nu.o center_indicator_update.o \
get_total_length.o get_arc_nu.o get_sur_nu.o

IFEM: $(OBJ)
	mpiifort -g -O0 -o IFEM $(OBJ) $(LIBS)
.f90.o:
	mpiifort -c -g $<
clean:
	rm -rf *.o *.mod IFEM
