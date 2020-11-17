include(ExternalProject)

macro(general_params)
	set(CMAKE_CXX_STANDARD 20)
	set_property(GLOBAL PROPERTY USE_FOLDERS ON)

	set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib/$<CONFIG>)
	set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib/$<CONFIG>)
	set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin/$<CONFIG>)

	if(MSVC)
		add_compile_options("/Zc:preprocessor" /wd"5105")
	endif()
endmacro()

macro(target_install)
	set(oneValueArgs TARGET INCLUDE_ROOT)
	cmake_parse_arguments(VAR "" "${oneValueArgs}" "" ${ARGN})

	install(TARGETS ${VAR_TARGET}
		CONFIGURATIONS Debug
		RUNTIME DESTINATION ./bin/Debug COMPONENT runtime
		ARCHIVE DESTINATION ./lib/Debug COMPONENT development
		LIBRARY DESTINATION ./lib/Debug COMPONENT development)
	install(TARGETS ${VAR_TARGET}
		CONFIGURATIONS Release
		RUNTIME DESTINATION ./bin/Release COMPONENT runtime
		ARCHIVE DESTINATION ./lib/Release COMPONENT development
		LIBRARY DESTINATION ./lib/Release COMPONENT development)
	install(DIRECTORY ${VAR_INCLUDE_ROOT}
		DESTINATION ./)
endmacro()

macro(default_filter)
	set(oneValueArgs HEADERS_ROOT SOURCES_ROOT CONTENT_ROOT INTERNAL_ROOT)
	set(multiValueArgs HEADERS SOURCES CONTENT INTERNAL)
	cmake_parse_arguments(VAR "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

	source_group(TREE "${VAR_HEADERS_ROOT}" PREFIX "Headers" FILES ${VAR_HEADERS})
	source_group(TREE "${VAR_SOURCES_ROOT}" PREFIX "Sources" FILES ${VAR_SOURCES})
	source_group(TREE "${VAR_CONTENT_ROOT}" PREFIX "Content" FILES ${VAR_CONTENT})
	source_group(TREE "${VAR_INTERNAL_ROOT}" PREFIX "Internal" FILES ${VAR_INTERNAL})
endmacro()

macro(setup_external_project_variables)
	set(${VAR_EXTERNAL_PROJECT}_PREFIX "${CMAKE_BINARY_DIR}/${VAR_EXTERNAL_PROJECT}")
	set(${VAR_EXTERNAL_PROJECT}_SOURCE_DIR "${${VAR_EXTERNAL_PROJECT}_PREFIX}/${VAR_EXTERNAL_PROJECT}")
	set(${VAR_EXTERNAL_PROJECT}_BINARY_DIR "${${VAR_EXTERNAL_PROJECT}_PREFIX}/${VAR_EXTERNAL_PROJECT}-build")
	set(${VAR_EXTERNAL_PROJECT}_DOWNLOAD_DIR "${${VAR_EXTERNAL_PROJECT}_SOURCE_DIR}" PARENT_SCOPE)
	set(${VAR_EXTERNAL_PROJECT}_STAMP_DIR "${${VAR_EXTERNAL_PROJECT}_PREFIX}/${VAR_EXTERNAL_PROJECT}-stamp")
	set(${VAR_EXTERNAL_PROJECT}_TMP_DIR "${${VAR_EXTERNAL_PROJECT}_PREFIX}/${VAR_EXTERNAL_PROJECT}-tmp")

	set(${VAR_EXTERNAL_PROJECT}_PREFIX ${${VAR_EXTERNAL_PROJECT}_PREFIX} PARENT_SCOPE)
	set(${VAR_EXTERNAL_PROJECT}_SOURCE_DIR ${${VAR_EXTERNAL_PROJECT}_SOURCE_DIR} PARENT_SCOPE)
	set(${VAR_EXTERNAL_PROJECT}_BINARY_DIR ${${VAR_EXTERNAL_PROJECT}_BINARY_DIR} PARENT_SCOPE)
	set(${VAR_EXTERNAL_PROJECT}_DOWNLOAD_DIR ${${VAR_EXTERNAL_PROJECT}_DOWNLOAD_DIR} PARENT_SCOPE)
	set(${VAR_EXTERNAL_PROJECT}_STAMP_DIR ${${VAR_EXTERNAL_PROJECT}_STAMP_DIR} PARENT_SCOPE)
	set(${VAR_EXTERNAL_PROJECT}_TMP_DIR ${${VAR_EXTERNAL_PROJECT}_TMP_DIR} PARENT_SCOPE)
endmacro()

function(add_external_project_cmake_download)
	set(options STANDARD_INSTALL)
	set(oneValueArgs EXTERNAL_PROJECT URL)
	set(multiValueArgs CMAKE_ARGS INSTALL_COMMAND)
	cmake_parse_arguments(VAR "${options}" "${oneValueArgs}" "${multiValueArgs}" "${ARGN}")

	setup_external_project_variables()

	ExternalProject_Add(${VAR_EXTERNAL_PROJECT}
		URL ${VAR_URL}
		CMAKE_ARGS ${VAR_CMAKE_ARGS} -DCMAKE_INSTALL_PREFIX=${CMAKE_BINARY_DIR}
		
		PREFIX ${${VAR_EXTERNAL_PROJECT}_PREFIX}
		BINARY_DIR ${${VAR_EXTERNAL_PROJECT}_BINARY_DIR}
		SOURCE_DIR ${${VAR_EXTERNAL_PROJECT}_SOURCE_DIR}
		STAMP_DIR ${${VAR_EXTERNAL_PROJECT}_STAMP_DIR}
		TMP_DIR ${${VAR_EXTERNAL_PROJECT}_TMP_DIR}
		DOWNLOAD_DIR ${${VAR_EXTERNAL_PROJECT}_DOWNLOAD_DIR}
		INSTALL_COMMAND ${VAR_INSTALL_COMMAND})
endfunction()

function(add_external_project_cmake)
	set(options STANDARD_INSTALL)
	set(oneValueArgs EXTERNAL_PROJECT GIT_REPOSITORY GIT_TAG)
	set(multiValueArgs CMAKE_ARGS INSTALL_COMMAND)
	cmake_parse_arguments(VAR "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

	setup_external_project_variables()

	ExternalProject_Add(${VAR_EXTERNAL_PROJECT}
		GIT_REPOSITORY ${VAR_GIT_REPOSITORY}
		GIT_TAG ${VAR_GIT_TAG}
		GIT_REMOTE_NAME origin
		CMAKE_ARGS ${VAR_CMAKE_ARGS} -DCMAKE_INSTALL_PREFIX=${CMAKE_BINARY_DIR}

		PREFIX ${${VAR_EXTERNAL_PROJECT}_PREFIX}
		BINARY_DIR ${${VAR_EXTERNAL_PROJECT}_BINARY_DIR}
		SOURCE_DIR ${${VAR_EXTERNAL_PROJECT}_SOURCE_DIR}
		STAMP_DIR ${${VAR_EXTERNAL_PROJECT}_STAMP_DIR}
		TMP_DIR ${${VAR_EXTERNAL_PROJECT}_TMP_DIR}
		DOWNLOAD_DIR ${${VAR_EXTERNAL_PROJECT}_DOWNLOAD_DIR}
		INSTALL_COMMAND ${VAR_INSTALL_COMMAND})
endfunction()

function(download_external_project)
	set(options STANDRAD_INSTALL)
	set(oneValueArgs EXTERNAL_PROJECT GIT_REPOSITORY GIT_TAG)
	set(multiValueArgs INSTALL_COMMAND BUILD_COMMAND CONFIGURE_COMMAND)
	cmake_parse_arguments(VAR "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

	setup_external_project_variables()

	ExternalProject_Add(${VAR_EXTERNAL_PROJECT}
		GIT_REPOSITORY ${VAR_GIT_REPOSITORY}
		GIT_TAG ${VAR_GIT_TAG}
		GIT_REMOTE_NAME origin
		
		PREFIX ${${VAR_EXTERNAL_PROJECT}_PREFIX}
		BINARY_DIR ${${VAR_EXTERNAL_PROJECT}_BINARY_DIR}
		SOURCE_DIR ${${VAR_EXTERNAL_PROJECT}_SOURCE_DIR}
		STAMP_DIR ${${VAR_EXTERNAL_PROJECT}_STAMP_DIR}
		TMP_DIR ${${VAR_EXTERNAL_PROJECT}_TMP_DIR}
		DOWNLOAD_DIR ${${VAR_EXTERNAL_PROJECT}_DOWNLOAD_DIR}
		
		INSTALL_COMMAND ""
		BUILD_COMMAND ""
		CONFIGURE_COMMAND ""
		TEST_COMMAND "")
endfunction()

function(target_reflect target apiDef)
    set(allowed_file_extensions h|hpp)
    set(excluded_file_patterns "pch")
    set(gen_dir_cpp "${CMAKE_BINARY_DIR}/gen/${target}/")

    get_target_property(sources ${target} SOURCES)

    if(NOT EXISTS "${gen_dir_cpp}/__global__.cpp")
        file(WRITE "${gen_dir_cpp}/__global__.cpp" "#include \"pch.h\"\n")
    endif()
    source_group("Generated" FILES "${gen_dir_cpp}/__global__.cpp")

    foreach(src ${sources})
        if(src MATCHES \\.\(${allowed_file_extensions}\)$ AND NOT src MATCHES ${excluded_file_patterns})
            get_filename_component(src_name ${src} NAME_WE)
            set(gen_cpp ${gen_dir_cpp}/${src_name}.g.cpp)
            
            list(APPEND generates_files ${gen_cpp})

            if(NOT EXISTS ${gen_cpp})
                file(WRITE ${gen_cpp} "#include \"pch.h\"\n")
            endif()

            add_custom_command(
                OUTPUT "${gen_cpp}"
                DEPENDS "${src}" "${CMAKE_BINARY_DIR}/bin/$<CONFIG>/Reflector${CMAKE_EXECUTABLE_SUFFIX}"
                COMMAND ${CMAKE_BINARY_DIR}/bin/$<CONFIG>/Reflector "${PROJECT_SOURCE_DIR}" "${src}" "${gen_cpp}" ${apiDef} ${target}
		COMMENT "[reflection] ${src}")

            target_sources(${target} PRIVATE ${gen_cpp})

            set_source_files_properties(${src} PROPERTIES GENERATED TRUE)
            source_group("Generated" FILES ${gen_cpp})
        endif()
    endforeach()

    target_sources(${target} PRIVATE "${gen_dir_cpp}/__global__.cpp")

    add_custom_command(
	OUTPUT "${gen_dir_cpp}/__global__.cpp"
	DEPENDS ${generated_files} "${CMAKE_BINARY_DIR}/bin/$<CONFIG>/Reflector${CMAKE_EXECUTABLE_SUFFIX}"
	COMMAND ${CMAKE_BINARY_DIR}/bin/$<CONFIG>/Reflector "${PROJECT_SOURCE_DIR}" "__global__" "${gen_dir_cpp}/__global__.cpp" ${apiDef} ${target}
	COMMENT "[reflection] __global__")

    target_include_directories(${target} PRIVATE ${gen_dir_h})
endfunction()

function(build_externals)
	configure_file(external/CMakeLists.txt external/CMakeLists.txt)
	execute_process(COMMAND ${CMAKE_COMMAND} -G "${CMAKE_GENERATOR}" "${CMAKE_CURRENT_BINARY_DIR}/external"
  		RESULT_VARIABLE result
  		WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/external/)
	if(result)
  		message(FATAL_ERROR "CMake step for externals failed: ${result}")
	endif()
	execute_process(COMMAND ${CMAKE_COMMAND} --build "${CMAKE_CURRENT_BINARY_DIR}/external"
  		RESULT_VARIABLE result
  		WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/external/)
	if(result)
  		message(FATAL_ERROR "Build step for externals failed: ${result}")
	endif()
endfunction()

