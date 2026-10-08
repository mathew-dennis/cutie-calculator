cmake_minimum_required(VERSION 3.16)
project(cutie-calculator VERSION 1.0 LANGUAGES CXX)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

find_package(Qt6 REQUIRED COMPONENTS Core Quick Qml)

qt_standard_project_setup()

qt_add_resources(APP_RESOURCES
	${CMAKE_SOURCE_DIR}/src/qml/qml.qrc)

qt_add_executable(cutie-calculator src/main.cpp ${APP_RESOURCES})

target_link_libraries(cutie-calculator PUBLIC Qt::Core Qt::Quick Qt::Qml)

install(TARGETS cutie-calculator RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}")
install(FILES cutie-calculator.desktop DESTINATION "${CMAKE_INSTALL_DATADIR}/applications")
install(FILES cutie-calculator.svg DESTINATION "${CMAKE_INSTALL_DATADIR}/icons/hicolor/scalable/apps")
