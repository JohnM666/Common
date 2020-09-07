macro(general_params)
	set(CMAKE_CXX_STANDARD 20)
	set_property(GLOBAL PROPERTY USE_FOLDERS ON)

	set(EXTERNAL_INSTALL_LOCATION ${CMAKE_SOURCE_DIR}/external/)
	set(CMAKE_INSTALL_PREFIX ${CMAKE_SOURCE_DIR}/.install)

	set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
	set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
	set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
endmacro()

macro(target_install)
	set(oneValueArgs TARGET INCLUDE_ROOT)
	cmake_parse_arguments(VAR "" "${oneValueArgs}" "" ${ARGN})

	if(${VAR_UNPARSED_ARGUMENTS} or ${VAR_KEYWORDS_MISSING_VALUES})
		message("Invalid arguments")
	else()
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
	endif()
endmacro()

function(add_external_project_cmake)
	set(options STANDARD_INSTALL)
	set(oneValueArgs EXTERNAL_PROJECT GIT_REPOSITORY GIT_TAG)
	set(multiValueArgs CMAKE_ARGS INSTALL_COMMAND)
	cmake_parse_arguments(PARSE_ARGV ${ARGC} VAR "${options}" "${oneValueArgs}" "${multiValueArgs}")

	if(${VAR_UNPARSED_ARGUMENTS} or ${VAR_KEYWORDS_MISSING_VALUES})
		message("Invalid arguments")
	else()
		set(${VAR_EXTERNAL_PROJECT}_PREFIX "${EXTERNAL_INSTALL_LOCATION}/${VAR_EXTERNAL_PROJECT}")
		set(${VAR_EXTERNAL_PROJECT}_SOURCE_DIR "${VAR_EXTERNAL_PROJECT}_PREFIX/${VAR_EXTERNAL_PROJECT}")
		set(${VAR_EXTERNAL_PROJECT}_BINARY_DIR "${VAR_EXTERNAL_PROJECT}_PREFIX/${VAR_EXTERNAL_PROJECT}-build")
		set(${VAR_EXTERNAL_PROJECT}_DOWNLOAD_DIR "${VAR_EXTERNAL_PROJECT}_SOURCE_DIR")
		set(${VAR_EXTERNAL_PROJECT}_STAMP_DIR "${VAR_EXTERNAL_PROJECT}_PREFIX/${VAR_EXTERNAL_PROJECT}-stamp")
		set(${VAR_EXTERNAL_PROJECT}_TMP_DIR "${VAR_EXTERNAL_PROJECT}_PREFIX/${VAR_EXTERNAL_PROJECT}-tmp")

		ExternalProject_Add(${VAR_EXTERNAL_PROJECT}
			GIT_REPOSITORY ${VAR_GIT_REPOSITORY}
			GIT_TAG ${VAR_GIT_TAG}
			GIT_REMOTE_NAME origin
			CMAKE_ARGS ${VAR_CMAKE_ARGS}

			PREFIX ${VAR_EXTERNAL_PROJECT}_PREFIX
			BINARY_DIR ${VAR_EXTERNAL_PROJECT}_BINARY_DIR
			SOURCE_DIR ${VAR_EXTERNAL_PROJECT}_SOURCE_DIR
			STAMP_DIR ${VAR_EXTERNAL_PROJECT}_STAMP_DIR
			TMP_DIR ${VAR_EXTERNAL_PROJECT}_TMP_DIR
			DOWNLOAD_DIR ${VAR_EXTERNAL_PROJECT}_DOWNLOAD_DIR
			INSTALL_COMMAND ${VAR_INSTALL_COMMAND})
	endif()
endfunction()