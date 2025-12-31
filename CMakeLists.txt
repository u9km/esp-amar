cmake_minimum_required(VERSION 3.10)
project(ESPSimulator)

set(CMAKE_CXX_STANDARD 17)

# إعدادات ImGui
set(IMGUI_DIR ${CMAKE_SOURCE_DIR}/external/imgui)

# البحث عن المكتبات المطلوبة
find_package(OpenGL REQUIRED)
find_package(GLFW3 REQUIRED)

# إعدادات المصادر
add_executable(ESPSimulator
    src/main.cpp
    src/ImGuiControlPanel.cpp
)

# روابط المكتبات
target_link_libraries(ESPSimulator
    ${OPENGL_LIBRARIES}
    glfw
)

# تضمين الأدلة
target_include_directories(ESPSimulator PRIVATE
    ${CMAKE_SOURCE_DIR}/src
    ${IMGUI_DIR}
    ${IMGUI_DIR}/backends
)