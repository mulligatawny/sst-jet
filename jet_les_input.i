Simulation:
  - name: NaluSim
    time_integrator: ti_1
    optimizer: opt1
    error_estimator: errest_1

linear_solvers:

  - name: solve_scalar
    type: tpetra
    method: gmres
    preconditioner: sgs
    tolerance: 1e-5
    max_iterations: 50
    kspace: 50
    output_level: 0

  - name: solve_cont
    type: tpetra
    method: gmres
    preconditioner: muelu 
    tolerance: 1e-5
    max_iterations: 100 
    kspace: 100 
    output_level: 0
    recompute_preconditioner: false
    muelu_xml_file_name: milestone_aspect_ratio_smooth.xml 

realms:

  - name: realm_1
    #mesh: ./delhi.exo 
    mesh: ./restart-2/jet.rst
    use_edges: no 
    #automatic_decomposition_type: rcb
   
    time_step_control:
     target_courant: 1.0
     time_step_change_factor: 1.25
   
    equation_systems:
      name: theEqSys
      max_iterations: 3 

      solver_system_specification:
        velocity: solve_scalar
        pressure: solve_cont
        mixture_fraction: solve_scalar
 
      systems:
        - LowMachEOM:
            name: myLowMach
            max_iterations: 1
            convergence_tolerance: 1e-5

        - MixtureFraction:
            name: myZ
            max_iterations: 1
            convergence_tolerance: 1.e-2

    initial_conditions:
      - constant: ic_1
        target_name: coflow-HEX 
        value:
          pressure: 0
          velocity: [1.4,0,0]
          mixture_fraction: 0.0

      - user_function: ic_2
        target_name: jet-HEX
        user_function_name: 
          velocity: SinProfilePipeFlow
        user_function_parameters:
          velocity: [27.7, 1.0,10,10,10]

    material_properties:
      target_name: [jet-HEX, coflow-HEX]
      specifications:

        - name: density
          type: mixture_fraction
          primary_value: 1.1
          secondary_value: 0.92

        - name: viscosity
          type: mixture_fraction
          primary_value: 1.7e-5
          secondary_value: 1.8e-5

    boundary_conditions:

    - inflow_boundary_condition: bc_inflowJet
      target_name: jet_inlet
      inflow_user_data:
        velocity: [27.7,0,0]
        mixture_fraction: 1.0

    - wall_boundary_condition: bc_pipeWall
      target_name: wall
      wall_user_data:
        velocity: [0,0,0]
        use_wall_function: yes

    - inflow_boundary_condition: bc_inflowX
      target_name: coflow_inlet 
      inflow_user_data:
        velocity: [1.4,0,0]
        mixture_fraction: 0.0

    - symmetry_boundary_condition: bc_top
      target_name: slip_wall
      symmetry_user_data:

    - open_boundary_condition: bc_open
      target_name: outlet
      open_user_data:
        pressure: 101325
        use_total_pressure: yes

    solution_options:
      name: myOptions
      turbulence_model: wale
      shift_cvfem_mdot: yes

      options:

        - projected_nodal_gradient:
            pressure: element
            velocity: edge
            mixture_fraction: edge

        - hybrid_factor:
            velocity: 0.0 
            mixture_fraction: 1.0

        - alpha_upw:
            mixture_fraction: 1.0 

        - laminar_schmidt:
            mixture_fraction: 0.7

        - turbulent_schmidt:
            mixture_fraction: 1.0

        - source_terms:
            continuity: density_time_derivative

        - limiter:
            pressure: no
            velocity: no
            mixture_fraction: yes

        - shifted_gradient_operator:
            velocity: no
            pressure: no
            mixture_fraction: no

        - user_constants:
            gravity: [9.81,0,0]
            reference_density: 0.92

        - peclet_function_form:
            velocity: tanh
            mixture_fraction: classic

        - peclet_function_tanh_transition:
            velocity: 1000.0
            mixture_fraction: 1e9

        - peclet_function_tanh_width:
            velocity: 25.0

    turbulence_averaging:
      forced_reset: no # SET THIS TO NO NEXT RESTART
      time_filter_interval: 100000.0
      specifications:
        - name: one
          target_name: [jet-HEX, coflow-HEX] 
          reynolds_averaged_variables:
            - velocity
            - mixture_fraction
            - pressure
            - reynolds_stress
            - sfs_stress
            - resolved_turbulent_ke
          favre_averaged_variables:
            - velocity
            - mixture_fraction
            - reynolds_stress

          compute_reynolds_stress: yes
          compute_tke: yes
          compute_sfs_stress: yes

    data_probes:

      output_frequency: 25
      search_tolerance: 1.0e-3
      search_expansion_factor: 2.0

      specifications:

        - name: x1_eig
          from_target_part: coflow-HEX

          line_of_site_specifications:
            - name: x1_eig
              number_of_points: 2048
              tip_coordinates: [0.415, 0.0, 0.0]
              tail_coordinates: [1.415, 0.0, 0.0]

          output_variables:
            - field_name: reynolds_stress_ra_one
              field_size: 6
            - field_name: velocity_ra_one
              field_size: 3



        - name: slice1_eig
          from_target_part: coflow-HEX

          line_of_site_specifications:
            - name: slice1_eig
              number_of_points: 2048
              tip_coordinates: [0.4216, 0.265, 0.0]
              tail_coordinates: [0.4216, -0.265, 0.0]

          output_variables:
            - field_name: reynolds_stress_ra_one
              field_size: 6
            - field_name: velocity_ra_one
              field_size: 3


        - name: slice2_eig
          from_target_part: coflow-HEX

          line_of_site_specifications:
            - name: slice2_eig
              number_of_points: 2048
              tip_coordinates: [0.59423, 0.265, 0.0]
              tail_coordinates: [0.59423, -0.265, 0.0]

          output_variables:
            - field_name: reynolds_stress_ra_one
              field_size: 6
            - field_name: velocity_ra_one
              field_size: 3


        - name: slice3_eig
          from_target_part: coflow-HEX

          line_of_site_specifications:
            - name: slice3_eig
              number_of_points: 2048
              tip_coordinates: [0.7505, 0.265, 0.0]
              tail_coordinates: [0.7505, -0.265, 0.0]

          output_variables:
            - field_name: reynolds_stress_ra_one
              field_size: 6
            - field_name: velocity_ra_one
              field_size: 3

#        - name: fig3_reset
#          from_target_part: coflow-HEX
#
#          line_of_site_specifications:
#            - name: fig3_reset
#              number_of_points: 2048
#              tip_coordinates: [0.415, 0.0, 0.0]
#              tail_coordinates: [1.415, 0.0, 0.0]
#
#          output_variables:
#            - field_name: velocity_ra_one
#              field_size: 3
#            - field_name: velocity_fa_one
#              field_size: 3
#            - field_name: mixture_fraction_fa_one
#              field_size: 1
#            - field_name: reynolds_stress_ra_one
#              field_size: 6
#            - field_name: reynolds_stress_fa_one
#              field_size: 6
#
#        - name: fig7b_1_reset
#          from_target_part: coflow-HEX
#
#          line_of_site_specifications:
#            - name: fig7b_1_reset
#              number_of_points: 2048
#              tip_coordinates: [0.4216, 0.265, 0.0]
#              tail_coordinates: [0.4216, 0.0, 0.0]
#
#          output_variables:
#            - field_name: velocity_ra_one
#              field_size: 3
#            - field_name: velocity_fa_one
#              field_size: 3
#            - field_name: mixture_fraction_fa_one
#              field_size: 1
#            - field_name: reynolds_stress_ra_one
#              field_size: 6
#            - field_name: reynolds_stress_fa_one
#              field_size: 6
#
#        - name: fig7b_2_reset
#          from_target_part: coflow-HEX
#
#          line_of_site_specifications:
#            - name: fig7b_2_reset
#              number_of_points: 2048
#              tip_coordinates: [0.59423, 0.265, 0.0]
#              tail_coordinates: [0.59423, 0.0, 0.0]
#
#          output_variables:
#            - field_name: velocity_ra_one
#              field_size: 3
#            - field_name: velocity_fa_one
#              field_size: 3
#            - field_name: mixture_fraction_fa_one
#              field_size: 1
#            - field_name: reynolds_stress_ra_one
#              field_size: 6
#            - field_name: reynolds_stress_fa_one
#              field_size: 6
#
#        - name: fig7b_3_reset
#          from_target_part: coflow-HEX
#
#          line_of_site_specifications:
#            - name: fig7b_3_reset
#              number_of_points: 2048
#              tip_coordinates: [0.7505, 0.265, 0.0]
#              tail_coordinates: [0.7505, 0.0, 0.0]
#
#          output_variables:
#            - field_name: velocity_ra_one
#              field_size: 3
#            - field_name: velocity_fa_one
#              field_size: 3
#            - field_name: mixture_fraction_fa_one
#              field_size: 1
#            - field_name: reynolds_stress_ra_one
#              field_size: 6
#            - field_name: reynolds_stress_fa_one
#              field_size: 6
#
#        - name: pipe_v_reset
#          from_target_part: jet-HEX
#
#          ring_specifications:
#
#            - name: pipe_v_reset
#              number_of_points: 128
#              number_of_line_points: 512
#              unit_normal: [1.0, 0.0, 0.0]
#              origin_coordinates: [0.41, 0.0, 0.0]
#              tip_coordinates: [0.41, 0.0055, 0.0]
#              tail_coordinates: [0.41, 0.0, 0.0]
#
#          output_variables:
#            - field_name: velocity_ra_one 
#              field_size: 3
#            - field_name: velocity_fa_one 
#              field_size: 3
#            - field_name: mixture_fraction_fa_one
#              field_size: 1
#            - field_name: reynolds_stress_ra_one
#              field_size: 6
#            - field_name: reynolds_stress_fa_one
#              field_size: 6
#
#        - name: fig7_1_reset
#          from_target_part: coflow-hex
#
#          ring_specifications:
#
#            - name: fig7_1_reset
#              number_of_points: 128 
#              number_of_line_points: 512
#              unit_normal: [1.0, 0.0, 0.0]
#              origin_coordinates: [0.4216, 0.0, 0.0]
#              tip_coordinates: [0.4216, 0.0, 0.0]
#              tail_coordinates: [0.4216, 0.265, 0.0]
#
#          output_variables:
#
#            - field_name: velocity_ra_one
#              field_size: 3
#            - field_name: velocity_fa_one
#              field_size: 3
#            - field_name: mixture_fraction_fa_one
#              field_size: 1
#            - field_name: reynolds_stress_ra_one
#              field_size: 6
#            - field_name: reynolds_stress_fa_one
#              field_size: 6
#
#        - name: fig7_2_reset
#          from_target_part: coflow-hex
#
#          ring_specifications:
#
#            - name: fig7_2_reset
#              number_of_points: 128  
#              number_of_line_points: 512
#              unit_normal: [1.0, 0.0, 0.0]
#              origin_coordinates: [0.59423, 0.0, 0.0]
#              tip_coordinates: [0.59423, 0.0, 0.0]
#              tail_coordinates: [0.59423, 0.265, 0.0]
#
#          output_variables:
#
#            - field_name: velocity_ra_one
#              field_size: 3
#            - field_name: velocity_fa_one
#              field_size: 3
#            - field_name: mixture_fraction_fa_one
#              field_size: 1
#            - field_name: reynolds_stress_ra_one
#              field_size: 6
#            - field_name: reynolds_stress_fa_one
#              field_size: 6
#
#        - name: fig7_3_reset
#          from_target_part: coflow-hex
#
#          ring_specifications:
#
#            - name: fig7_3_reset
#              number_of_points: 128  
#              number_of_line_points: 512
#              unit_normal: [1.0, 0.0, 0.0]
#              origin_coordinates: [0.7505, 0.0, 0.0]
#              tip_coordinates: [0.7505, 0.0, 0.0]
#              tail_coordinates: [0.7505, 0.265, 0.0]
#
#          output_variables:
#            - field_name: velocity_ra_one
#              field_size: 3
#            - field_name: velocity_fa_one
#              field_size: 3
#            - field_name: mixture_fraction_fa_one
#              field_size: 1
#            - field_name: reynolds_stress_ra_one
#              field_size: 6
#            - field_name: reynolds_stress_fa_one
#              field_size: 6
#
#        - name: pipe_v_tke_reset
#          from_target_part: jet-HEX
#
#          ring_specifications:
#
#            - name: pipe_v_tke_reset
#              number_of_points: 128
#              number_of_line_points: 512
#              unit_normal: [1.0, 0.0, 0.0]
#              origin_coordinates: [0.41, 0.0, 0.0]
#              tip_coordinates: [0.41, 0.0055, 0.0]
#              tail_coordinates: [0.41, 0.0, 0.0]
#
#          output_variables:
#            - field_name: resolved_turbulent_ke_ra_one
#              field_size: 1
#            - field_name: sfs_stress_ra_one
              field_size: 6

    output:
      output_data_base_name: ./output/jet.e
      output_frequency: 5000 
      output_node_set: no 
      output_variables:
       - velocity
       - velocity_ra_one
       - velocity_fa_one
       - pressure
       - pressure_ra_one
       - mixture_fraction
       - mixture_fraction_ra_one
       - mixture_fraction_fa_one
       - reynolds_stress
       - reynolds_stress_ra_one
       - reynolds_stress_fa_one
       - resolved_turbulent_ke_ra_one

    restart:
      restart_data_base_name: ./restart-2/jet.rst
      restart_frequency: 5000
      restart_time: 10000000

Time_Integrators:
  - StandardTimeIntegrator:
      name: ti_1
      start_time: 0
      termination_step_count: 1000000
      time_step: 1.0e-6
      time_stepping_type: adaptive
      time_step_count: 0
      second_order_accuracy: yes 

      realms: 
        - realm_1
