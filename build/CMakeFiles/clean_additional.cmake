# Additional clean files
cmake_minimum_required(VERSION 3.16)

if("${CONFIG}" STREQUAL "" OR "${CONFIG}" STREQUAL "Debug")
  file(REMOVE_RECURSE
  "CMakeFiles\\SparkExamAI_autogen.dir\\AutogenUsed.txt"
  "CMakeFiles\\SparkExamAI_autogen.dir\\ParseCache.txt"
  "QXlsx\\CMakeFiles\\QXlsx_autogen.dir\\AutogenUsed.txt"
  "QXlsx\\CMakeFiles\\QXlsx_autogen.dir\\ParseCache.txt"
  "QXlsx\\QXlsx_autogen"
  "SparkExamAI_autogen"
  )
endif()
