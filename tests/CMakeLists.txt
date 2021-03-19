add_executable(Test Test.cpp)
target_link_libraries(Test PRIVATE OpenSSL::SSL)

install( TARGETS Test
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib )
add_test(NAME Test COMMAND Test)
