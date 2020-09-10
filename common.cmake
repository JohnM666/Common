include(ExternalProject)

macro(general_params)
	set(CMAKE_CXX_STANDARD 20)
	set_property(GLOBAL PROPERTY USE_FOLDERS ON)

	set(EXTERNAL_DOWNLOAD_DIR ${CMAKE_BINARY_DIR}/external/ CACHE PATH "Target directory for download external libraries")
	set(ROOT_BINARY_DIR ${CMAKE_BINARY_DIR} CACHE PATH "Binary directory of top level project")

	set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
	set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
	set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
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
	set(oneValueArgs HEADERS_ROOT SOURCES_ROOT CONTENT_ROOT)
	set(multiValueArgs HEADERS SOURCES CONTENT)
	cmake_parse_arguments(VAR "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

	source_group(TREE "${VAR_HEADERS_ROOT}" PREFIX "Headers" FILES ${VAR_HEADERS})
	source_group(TREE "${VAR_SOURCES_ROOT}" PREFIX "Sources" FILES ${VAR_SOURCES})
	source_group(TREE "${VAR_CONTENT_ROOT}" PREFIX "Content" FILES ${VAR_CONTENT})
endmacro()

function(add_external_project_cmake)
	set(options STANDARD_INSTALL)
	set(oneValueArgs EXTERNAL_PROJECT GIT_REPOSITORY GIT_TAG)
	set(multiValueArgs CMAKE_ARGS INSTALL_COMMAND)
	cmake_parse_arguments(VAR "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

	set(${VAR_EXTERNAL_PROJECT}_PREFIX "${EXTERNAL_DOWNLOAD_DIR}/${VAR_EXTERNAL_PROJECT}")
	set(${VAR_EXTERNAL_PROJECT}_SOURCE_DIR "${${VAR_EXTERNAL_PROJECT}_PREFIX}/${VAR_EXTERNAL_PROJECT}")
	set(${VAR_EXTERNAL_PROJECT}_BINARY_DIR "${${VAR_EXTERNAL_PROJECT}_PREFIX}/${VAR_EXTERNAL_PROJECT}-build")
	set(${VAR_EXTERNAL_PROJECT}_DOWNLOAD_DIR "${${VAR_EXTERNAL_PROJECT}_SOURCE_DIR}" PARENT_SCOPE)
	set(${VAR_EXTERNAL_PROJECT}_STAMP_DIR "${${VAR_EXTERNAL_PROJECT}_PREFIX}/${VAR_EXTERNAL_PROJECT}-stamp")
	set(${VAR_EXTERNAL_PROJECT}_TMP_DIR "${${VAR_EXTERNAL_PROJECT}_PREFIX}/${VAR_EXTERNAL_PROJECT}-tmp")

	set(EX_${VAR_EXTERNAL_PROJECT}_PREFIX ${${VAR_EXTERNAL_PROJECT}_PREFIX} PARENT_SCOPE)
	set(EX_${VAR_EXTERNAL_PROJECT}_SOURCE_DIR ${${VAR_EXTERNAL_PROJECT}_SOURCE_DIR} PARENT_SCOPE)
	set(EX_${VAR_EXTERNAL_PROJECT}_BINARY_DIR ${${VAR_EXTERNAL_PROJECT}_BINARY_DIR} PARENT_SCOPE)
	set(EX_${VAR_EXTERNAL_PROJECT}_DOWNLOAD_DIR ${${VAR_EXTERNAL_PROJECT}_DOWNLOAD_DIR} PARENT_SCOPE)
	set(EX_${VAR_EXTERNAL_PROJECT}_STAMP_DIR ${${VAR_EXTERNAL_PROJECT}_STAMP_DIR} PARENT_SCOPE)
	set(EX_${VAR_EXTERNAL_PROJECT}_TMP_DIR ${${VAR_EXTERNAL_PROJECT}_TMP_DIR} PARENT_SCOPE)

	ExternalProject_Add(${VAR_EXTERNAL_PROJECT}
		GIT_REPOSITORY ${VAR_GIT_REPOSITORY}
		GIT_TAG ${VAR_GIT_TAG}
		GIT_REMOTE_NAME origin
		CMAKE_ARGS ${VAR_CMAKE_ARGS}

		PREFIX ${${VAR_EXTERNAL_PROJECT}_PREFIX}
		BINARY_DIR ${${VAR_EXTERNAL_PROJECT}_BINARY_DIR}
		SOURCE_DIR ${${VAR_EXTERNAL_PROJECT}_SOURCE_DIR}
		STAMP_DIR ${${VAR_EXTERNAL_PROJECT}_STAMP_DIR}
		TMP_DIR ${${VAR_EXTERNAL_PROJECT}_TMP_DIR}
		DOWNLOAD_DIR ${${VAR_EXTERNAL_PROJECT}_DOWNLOAD_DIR}
		INSTALL_COMMAND ${VAR_INSTALL_COMMAND})
endfunction()