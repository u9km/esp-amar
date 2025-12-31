#pragma once
#include <imgui.h>
#include <vector>
#include <string>
#include <functional>

namespace EducationalESP {
    
// حالة النظام
struct SystemState {
    // إعدادات عامة
    bool systemActive = false;
    bool showMenu = true;
    
    // ميزات ESP
    struct {
        bool enabled = false;
        bool showBoxes = true;
        bool showHealth = true;
        bool showNames = true;
        bool showDistance = true;
        bool showSnaplines = false;
        bool showSkeleton = false;
        
        // ألوان
        ImColor enemyColor = ImColor(255, 50, 50, 255);
        ImColor teammateColor = ImColor(50, 150, 255, 255);
        ImColor botColor = ImColor(150, 50, 255, 255);
        
        // إعدادات التصفية
        float maxDistance = 500.0f;
        bool showEnemies = true;
        bool showTeammates = true;
        bool showBots = true;
        bool showItems = false;
        bool showVehicles = true;
    } esp;
    
    // ميزات Aim
    struct {
        bool enabled = false;
        int aimKey = 2; // 1=Left Click, 2=Right Click, 3=Middle, 4=Side buttons
        float smoothness = 2.5f;
        float fieldOfView = 3.0f;
        int aimBone = 0; // 0=Head, 1=Chest, 2=Stomach, 3=Legs
        
        bool autoShoot = false;
        bool silentAim = false;
        bool prediction = true;
        bool visibleCheck = true;
        
        // إحصائيات
        int shotsFired = 0;
        int hits = 0;
        float accuracy = 0.0f;
    } aim;
    
    // ميزات المراقبة
    struct {
        bool radarEnabled = false;
        bool showRadar = true;
        float radarZoom = 1.0f;
        
        bool spectatorList = false;
        bool damageIndicator = true;
        bool soundAlert = false;
        
        bool noRecoil = false;
        bool noSpread = false;
        bool instantHit = false;
    } misc;
    
    // ميزات المركبة
    struct {
        bool autoRepair = false;
        bool infiniteFuel = false;
        bool vehicleESP = true;
        float vehicleHealth = 100.0f;
    } vehicle;
    
    // إعدادات الواجهة
    struct {
        int menuKey = VK_INSERT;
        ImVec4 backgroundColor = ImVec4(0.08f, 0.08f, 0.08f, 0.94f);
        float menuOpacity = 0.95f;
        int fontSize = 16;
        
        // ألوان القائمة
        ImColor activeColor = ImColor(0, 200, 100, 255);
        ImColor inactiveColor = ImColor(200, 50, 50, 255);
        ImColor textColor = ImColor(220, 220, 220, 255);
    } ui;
};

class ControlPanel {
private:
    SystemState state;
    bool hotkeys[5] = {false, false, false, false, false};
    float colors[3] = {0.4f, 0.6f, 0.8f};
    
    // قائمة المفاتيح للاختيار
    const char* keyNames[12] = {
        "None", "Left Click", "Right Click", "Middle Click",
        "X1 Button", "X2 Button", "Insert", "Delete",
        "Home", "End", "F1", "F2"
    };
    
    // عظام للاختيار
    const char* boneNames[6] = {
        "Head", "Neck", "Chest", "Stomach", "Pelvis", "Random"
    };
    
public:
    ControlPanel() {
        // إعدادات أولية
        state.systemActive = true;
    }
    
    void Render() {
        if (!state.showMenu) return;
        
        // بداية النافذة
        ImGui::SetNextWindowSize(ImVec2(600, 700), ImGuiCond_FirstUseEver);
        ImGui::Begin("📱 نظام التحكم التعليمي - ESP Simulator", &state.showMenu, 
                     ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_MenuBar);
        
        // شريط القوائم
        if (ImGui::BeginMenuBar()) {
            if (ImGui::BeginMenu("ملف")) {
                if (ImGui::MenuItem("حفظ الإعدادات")) SaveSettings();
                if (ImGui::MenuItem("تحميل الإعدادات")) LoadSettings();
                ImGui::Separator();
                if (ImGui::MenuItem("خروج")) state.showMenu = false;
                ImGui::EndMenu();
            }
            if (ImGui::BeginMenu("المساعدة")) {
                if (ImGui::MenuItem("عن البرنامج")) ShowAbout();
                ImGui::EndMenu();
            }
            ImGui::EndMenuBar();
        }
        
        // علامات التبويب
        ImGui::BeginTabBar("MainTabs");
        
        if (ImGui::BeginTabItem("🎯 نظام الرؤية (ESP)")) {
            RenderESPTab();
            ImGui::EndTabItem();
        }
        
        if (ImGui::BeginTabItem("🎮 نظام التصويب (Aim)")) {
            RenderAimTab();
            ImGui::EndTabItem();
        }
        
        if (ImGui::BeginTabItem("📡 أدوات مساعدة")) {
            RenderMiscTab();
            ImGui::EndTabItem();
        }
        
        if (ImGui::BeginTabItem("⚙️ الإعدادات")) {
            RenderSettingsTab();
            ImGui::EndTabItem();
        }
        
        ImGui::EndTabBar();
        
        // شريط الحالة السفلي
        ImGui::Separator();
        ImGui::Text("الحالة: %s | FPS: %.1f | الذاكرة: %.2f MB", 
                   state.systemActive ? "✅ نشط" : "❌ معطل", 
                   1.0f / ImGui::GetIO().DeltaTime,
                   GetMemoryUsage());
        
        ImGui::SameLine(ImGui::GetWindowWidth() - 120);
        if (ImGui::Button(state.systemActive ? "إيقاف النظام" : "تشغيل النظام", 
                         ImVec2(100, 25))) {
            state.systemActive = !state.systemActive;
            ToggleSystem();
        }
        
        ImGui::End();
    }
    
private:
    void RenderESPTab() {
        ImGui::Columns(2, "ESPColumns", true);
        
        // العمود الأول: الميزات الرئيسية
        ImGui::BeginChild("ESPFeatures", ImVec2(0, 300), true);
        
        ImGui::Checkbox("تفعيل نظام الرؤية (ESP)", &state.esp.enabled);
        ImGui::Separator();
        
        if (state.esp.enabled) {
            ImGui::Checkbox("إظهار المربعات حول اللاعبين", &state.esp.showBoxes);
            ImGui::Checkbox("إظهار أشرطة الصحة", &state.esp.showHealth);
            ImGui::Checkbox("إظهار الأسماء", &state.esp.showNames);
            ImGui::Checkbox("إظهار المسافات", &state.esp.showDistance);
            ImGui::Checkbox("إظهار خطوط التوجيه", &state.esp.showSnaplines);
            ImGui::Checkbox("إظهار الهيكل العظمي", &state.esp.showSkeleton);
            
            ImGui::Separator();
            ImGui::SliderFloat("أقصى مسافة", &state.esp.maxDistance, 50.0f, 1000.0f, "%.1f م");
            
            ImGui::Separator();
            ImGui::Text("تصفية العرض:");
            ImGui::Checkbox("الأعداء", &state.esp.showEnemies);
            ImGui::Checkbox("زملاء الفريق", &state.esp.showTeammates);
            ImGui::Checkbox("الروبوتات", &state.esp.showBots);
            ImGui::Checkbox("المركبات", &state.esp.showVehicles);
            ImGui::Checkbox("الأغراض", &state.esp.showItems);
        }
        
        ImGui::EndChild();
        
        // العمود الثاني: الألوان والإعدادات
        ImGui::NextColumn();
        
        ImGui::BeginChild("ESPColors", ImVec2(0, 300), true);
        
        ImGui::Text("تخصيص الألوان:");
        ImGui::ColorEdit3("لون الأعداء", (float*)&state.esp.enemyColor);
        ImGui::ColorEdit3("لون الزملاء", (float*)&state.esp.teammateColor);
        ImGui::ColorEdit3("لون الروبوتات", (float*)&state.esp.botColor);
        
        ImGui::Separator();
        ImGui::Text("إعدادات متقدمة:");
        
        ImGui::Checkbox("تحديث ديناميكي", &hotkeys[0]);
        ImGui::Checkbox("تنعيم الحركة", &hotkeys[1]);
        ImGui::Checkbox("تحسين الأداء", &hotkeys[2]);
        
        ImGui::Separator();
        ImGui::Text("إحصائيات:");
        ImGui::Text("الكائنات المرئية: %d", 12);
        ImGui::Text("المسافة المتوسطة: %.1f م", 245.5f);
        ImGui::Text("معدل التحديث: %.0f Hz", 60.0f);
        
        ImGui::EndChild();
        
        ImGui::Columns(1);
        
        // منطقة المعاينة
        ImGui::BeginChild("PreviewArea", ImVec2(0, 150), true);
        ImGui::Text("💡 معاينة ESP (للأغراض التعليمية فقط):");
        ImGui::Text("👤 [Enemy] John - ❤️ 75%% - 📏 150m");
        ImGui::Text("👤 [Teammate] Mike - ❤️ 100%% - 📏 50m");
        ImGui::Text("🤖 [Bot] Bot_001 - ❤️ 50%% - 📏 300m");
        ImGui::Text("🚗 [Vehicle] UAZ - ⛽ 80%% - 📏 200m");
        ImGui::EndChild();
    }
    
    void RenderAimTab() {
        ImGui::Columns(2, "AimColumns", true);
        
        // العمود الأول: إعدادات التصويب
        ImGui::BeginChild("AimSettings", ImVec2(0, 250), true);
        
        ImGui::Checkbox("تفعيل المساعدة على التصويب", &state.aim.enabled);
        ImGui::Separator();
        
        if (state.aim.enabled) {
            ImGui::Combo("زر التصويب", &state.aim.aimKey, keyNames, 12);
            ImGui::SliderFloat("السلاسة", &state.aim.smoothness, 1.0f, 10.0f, "%.1f");
            ImGui::SliderFloat("زاوية التصويب", &state.aim.fieldOfView, 1.0f, 10.0f, "%.1f°");
            ImGui::Combo("هدف التصويب", &state.aim.aimBone, boneNames, 6);
            
            ImGui::Separator();
            ImGui::Checkbox("إطلاق نار آلي", &state.aim.autoShoot);
            ImGui::Checkbox("تصويب خفي", &state.aim.silentAim);
            ImGui::Checkbox("توقع الحركة", &state.aim.prediction);
            ImGui::Checkbox("فحص الرؤية", &state.aim.visibleCheck);
        }
        
        ImGui::EndChild();
        
        // العمود الثاني: الإحصائيات
        ImGui::NextColumn();
        
        ImGui::BeginChild("AimStats", ImVec2(0, 250), true);
        
        ImGui::Text("📊 إحصائيات التصويب:");
        ImGui::Separator();
        
        ImGui::Text("الطلقات المطلقة: %d", state.aim.shotsFired);
        ImGui::Text("الإصابات: %d", state.aim.hits);
        
        state.aim.accuracy = state.aim.shotsFired > 0 ? 
                           (float)state.aim.hits / state.aim.shotsFired * 100.0f : 0.0f;
        
        ImGui::Text("الدقة: %.1f%%", state.aim.accuracy);
        
        // شريط التقدم للدقة
        ImGui::ProgressBar(state.aim.accuracy / 100.0f, ImVec2(-1, 20));
        
        ImGui::Separator();
        ImGui::Text("أدوات التصويب:");
        
        if (ImGui::Button("اختبار التصويب", ImVec2(-1, 25))) {
            TestAim();
        }
        
        if (ImGui::Button("إعادة تعيين الإحصائيات", ImVec2(-1, 25))) {
            state.aim.shotsFired = 0;
            state.aim.hits = 0;
        }
        
        ImGui::EndChild();
        
        ImGui::Columns(1);
        
        // إعدادات متقدمة
        ImGui::BeginChild("AdvancedAim", ImVec2(0, 150), true);
        
        ImGui::Text("⚙️ إعدادات متقدمة:");
        ImGui::Checkbox("إزالة الارتداد", &state.misc.noRecoil);
        ImGui::SameLine();
        ImGui::Checkbox("إزالة التبعثر", &state.misc.noSpread);
        ImGui::SameLine();
        ImGui::Checkbox("إصابة فورية", &state.misc.instantHit);
        
        ImGui::Separator();
        ImGui::Text("حساسية التصويب:");
        
        static float sensitivity[4] = {1.0f, 1.0f, 0.8f, 1.2f};
        ImGui::SliderFloat("عام", &sensitivity[0], 0.1f, 5.0f);
        ImGui::SliderFloat("التكبير", &sensitivity[1], 0.1f, 3.0f);
        ImGui::SliderFloat("الرشاش", &sensitivity[2], 0.1f, 2.0f);
        ImGui::SliderFloat("القناص", &sensitivity[3], 0.1f, 2.0f);
        
        ImGui::EndChild();
    }
    
    void RenderMiscTab() {
        ImGui::Columns(2, "MiscColumns", true);
        
        // العمود الأول: أدوات المراقبة
        ImGui::BeginChild("Monitoring", ImVec2(0, 200), true);
        
        ImGui::Text("📡 أدوات المراقبة:");
        ImGui::Checkbox("رادار", &state.misc.radarEnabled);
        if (state.misc.radarEnabled) {
            ImGui::Checkbox("إظهار الرادار", &state.misc.showRadar);
            ImGui::SliderFloat("تكبير الرادار", &state.misc.radarZoom, 0.5f, 3.0f);
        }
        
        ImGui::Separator();
        ImGui::Checkbox("قائمة المراقبين", &state.misc.spectatorList);
        ImGui::Checkbox("مؤشر الضرر", &state.misc.damageIndicator);
        ImGui::Checkbox("تنبيه صوتي", &state.misc.soundAlert);
        
        ImGui::EndChild();
        
        // العمود الثاني: ميزات المركبة
        ImGui::NextColumn();
        
        ImGui::BeginChild("Vehicle", ImVec2(0, 200), true);
        
        ImGui::Text("🚗 ميزات المركبة:");
        ImGui::Checkbox("تصليح آلي", &state.vehicle.autoRepair);
        ImGui::Checkbox("وقود لا ينتهي", &state.vehicle.infiniteFuel);
        ImGui::Checkbox("رؤية المركبات", &state.vehicle.vehicleESP);
        
        if (state.vehicle.vehicleESP) {
            ImGui::SliderFloat("صحة المركبة", &state.vehicle.vehicleHealth, 0.0f, 100.0f);
        }
        
        ImGui::EndChild();
        
        ImGui::Columns(1);
        
        // أزرار سريعة
        ImGui::BeginChild("QuickActions", ImVec2(0, 120), true);
        
        ImGui::Text("⚡ أزرار سريعة:");
        
        if (ImGui::Button("تفعيل الكل", ImVec2(100, 30))) EnableAll();
        ImGui::SameLine();
        if (ImGui::Button("إيقاف الكل", ImVec2(100, 30))) DisableAll();
        ImGui::SameLine();
        if (ImGui::Button("إعدادات افتراضية", ImVec2(150, 30))) ResetToDefault();
        
        ImGui::SameLine();
        if (ImGui::Button("حفظ الملف", ImVec2(100, 30))) SaveConfig();
        
        ImGui::EndChild();
        
        // معلومات النظام
        ImGui::BeginChild("SystemInfo", ImVec2(0, 100), true);
        
        ImGui::Text("🖥️ معلومات النظام:");
        ImGui::Text("الوقت: %.1f ثانية", ImGui::GetTime());
        ImGui::Text("الإصدار: 1.0.0 (تعليمي)");
        ImGui::Text("الحالة: %s", IsSystemReady() ? "جاهز" : "غير جاهز");
        
        ImGui::EndChild();
    }
    
    void RenderSettingsTab() {
        ImGui::BeginChild("UISettings", ImVec2(0, 250), true);
        
        ImGui::Text("🎨 إعدادات الواجهة:");
        ImGui::Separator();
        
        ImGui::Combo("زر فتح القائمة", &state.ui.menuKey, keyNames, 12);
        ImGui::ColorEdit4("لون الخلفية", (float*)&state.ui.backgroundColor);
        ImGui::SliderFloat("شفافية القائمة", &state.ui.menuOpacity, 0.5f, 1.0f);
        ImGui::SliderInt("حجم الخط", &state.ui.fontSize, 12, 24);
        
        ImGui::Separator();
        ImGui::Text("الألوان:");
        ImGui::ColorEdit3("لون النشط", (float*)&state.ui.activeColor);
        ImGui::ColorEdit3("لون غير النشط", (float*)&state.ui.inactiveColor);
        ImGui::ColorEdit3("لون النص", (float*)&state.ui.textColor);
        
        ImGui::EndChild();
        
        ImGui::BeginChild("HotkeySettings", ImVec2(0, 200), true);
        
        ImGui::Text("🎹 المفاتيح السريعة:");
        ImGui::Separator();
        
        ImGui::Text("ESP: Ctrl + E");
        ImGui::Text("Aim: Ctrl + A");
        ImGui::Text("Radar: Ctrl + R");
        ImGui::Text("Menu: Insert");
        
        ImGui::Separator();
        if (ImGui::Button("تخصيص المفاتيح", ImVec2(-1, 30))) {
            ShowHotkeyCustomizer();
        }
        
        ImGui::EndChild();
        
        ImGui::BeginChild("Config", ImVec2(0, 120), true);
        
        ImGui::Text("💾 الإعدادات:");
        
        if (ImGui::Button("تصدير الإعدادات", ImVec2(150, 30))) ExportConfig();
        ImGui::SameLine();
        if (ImGui::Button("استيراد الإعدادات", ImVec2(150, 30))) ImportConfig();
        
        ImGui::SameLine();
        if (ImGui::Button("استعادة الإعدادات", ImVec2(150, 30))) RestoreConfig();
        
        ImGui::EndChild();
    }
    
    // الدوال المساعدة
    void ToggleSystem() {
        if (state.systemActive) {
            // كود تفعيل النظام (تعليمي)
            InitializeSystem();
        } else {
            // كود إيقاف النظام (تعليمي)
            ShutdownSystem();
        }
    }
    
    void InitializeSystem() {
        // كود بدء النظام (للتجربة التعليمية)
        printf("[System] Initializing ESP Simulator...\n");
    }
    
    void ShutdownSystem() {
        // كود إيقاف النظام (للتجربة التعليمية)
        printf("[System] Shutting down ESP Simulator...\n");
    }
    
    void SaveSettings() {
        // حفظ الإعدادات (تعليمي)
        printf("[System] Settings saved!\n");
    }
    
    void LoadSettings() {
        // تحميل الإعدادات (تعليمي)
        printf("[System] Settings loaded!\n");
    }
    
    void TestAim() {
        // اختبار التصويب (تعليمي)
        state.aim.shotsFired += 10;
        state.aim.hits += 7;
        printf("[Aim] Test completed!\n");
    }
    
    void EnableAll() {
        state.esp.enabled = true;
        state.aim.enabled = true;
        state.misc.radarEnabled = true;
        printf("[System] All features enabled!\n");
    }
    
    void DisableAll() {
        state.esp.enabled = false;
        state.aim.enabled = false;
        state.misc.radarEnabled = false;
        printf("[System] All features disabled!\n");
    }
    
    void ResetToDefault() {
        state = SystemState();
        printf("[System] Reset to default settings!\n");
    }
    
    float GetMemoryUsage() {
        // محاكاة استخدام الذاكرة
        return 45.7f;
    }
    
    bool IsSystemReady() {
        return state.systemActive;
    }
    
    void ShowAbout() {
        ImGui::OpenPopup("عن البرنامج");
        if (ImGui::BeginPopupModal("عن البرنامج", NULL, ImGuiWindowFlags_AlwaysAutoResize)) {
            ImGui::Text("نظام محاكاة ESP تعليمي");
            ImGui::Text("الإصدار: 1.0.0 (أغراض تعليمية فقط)");
            ImGui::Text("هذا المشروع مخصص للأغراض التعليمية فقط");
            ImGui::Text("ولا يجب استخدامه في أي لعبة تجارية");
            ImGui::Separator();
            if (ImGui::Button("موافق", ImVec2(120, 0))) {
                ImGui::CloseCurrentPopup();
            }
            ImGui::EndPopup();
        }
    }
    
    void ShowHotkeyCustomizer() {
        // يمكن إضافة محدد المفاتيح هنا
        printf("[System] Hotkey customizer opened!\n");
    }
    
    void SaveConfig() {
        printf("[System] Configuration saved!\n");
    }
    
    void ExportConfig() {
        printf("[System] Configuration exported!\n");
    }
    
    void ImportConfig() {
        printf("[System] Configuration imported!\n");
    }
    
    void RestoreConfig() {
        printf("[System] Configuration restored!\n");
    }
};

} // namespace EducationalESP