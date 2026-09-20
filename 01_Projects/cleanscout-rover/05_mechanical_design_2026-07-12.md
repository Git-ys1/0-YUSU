# 2026-07-12 CleanScout Rover 机械结构重构

## Scope

本轮只覆盖 CleanScout Rover 的整车机械概念和可编辑 SolidWorks 模型，不替代下位机、OrangePi AI 或 Vue3 切片记忆。

- 输入模型：`F:\AcademicHub\000资料相关\26-27大创\模型\260711_2`
- 输出模型：`F:\AcademicHub\000资料相关\26-27大创\模型\260712_3_CleanScout_redesign`
- 主总装：`CleanScout_285x185_重构总装.SLDASM`
- 工具链：本机 SOLIDWORKS 2024 SP5，revision `32.5.0`

## Verified design decisions

1. 旧底盘核心包络约 `260 x 240 mm`，接近正方形；新车身改为 `285 x 185 mm`，含轮总包络 `285 x 264 x 90 mm`。
2. SolidWorks 坐标继续沿用旧模型习惯：`X/Z` 为底盘平面，`Y` 为车高。
3. 前部改成低矮封闭舱，顶面高度 `37 mm`；机械臂底座与雷达底座在同一纵向中心线上叠放。
4. 旧顶壳实体反求的接口继续保留：雷达 `42 x 42 mm`，机械臂 `70 x 70 mm`。
5. 雷达环形凸台顶面到机械臂板底面净高为 `30 mm`；真实雷达超过该高度时，优先提高四根承重柱，不再把雷达移回车头外伸板。
6. 树莓派/OpenRF1 使用后半区一侧立式叠放底座，第三控制板放另一侧，中间留给风道和垃圾盒。
7. 风道改为 `40 x 40 mm` 直通烟囱，外壳、顶端风机法兰和左右承重翼共同承担上层载荷。
8. 垃圾盒改为后抽拉式紧凑盒体，位于直通风道正下方。
9. 当前总装里的轮子和电机是包络参考件；最终实物化前要替换回项目已有详细零件，再补电机安装孔和配合。

## Verification evidence

- SolidWorks `OpenDoc6` 打开最终总装：errors `0`，warnings `0`。
- 总装包络：`[-142.5,0,-132]..[142.5,90,132] mm`。
- 最终总装包含 9 个未压缩组件。
- 雷达/机械臂双层桥复开：errors `0`，warnings `0`。
- 实体圆柱面检查确认：雷达通孔半径 `1.7 mm`，机械臂通孔半径 `1.75 mm`，且环形凸台内外圆同轴。
- 已输出 7 个结构件 STL、7 个结构件 STEP 和总装 STEP。

## Tooling lessons

- PowerShell 直接使用 `New-Object -ComObject SldWorks.Application` 会在该安装上触发 `TYPE_E_ELEMENTNOTFOUND`；通过安装目录里的 `SolidWorks.Interop.sldworks.dll` 编译早绑定 C# 调用可正常工作。
- `IModeler.CreateBodyFromBox3(double[])` 在当前环境触发 `DISP_E_ARRAYISLOCKED`；最终稳定路径是原生草图 + `FeatureExtrusion3`。
- 偏置盲切 `FeatureCut3` 参数组合不稳定。孔、环形凸台、方形风道和风机开口可在同一草图中用多重闭合轮廓一次拉伸，避免后切除。
- `AddComponent5(x,y,z)` 的实测定位语义是把给定点作为组件包络中心；不能假设零件内部全局坐标会自动保留。必须显式写定位表并用 `IAssemblyDoc.GetBox` / `IComponent2.GetBox` 复核。
- `gb_part.prtdot` 中前视基准面为 `XY`，上视基准面为 `XZ`；上视草图第二轴对应 `-Z`。本项目的物理车高是 `Y`。

## Memory Routing Audit

| Candidate Lesson | Route | Target File | Action | Evidence |
|---|---|---|---|---|
| CleanScout 285 x 185 车身、同轴雷达/机械臂、立式板卡和直通风道 | project-only | `01_Projects/cleanscout-rover/05_mechanical_design_2026-07-12.md` | written | final SLDASM/STEP and zero-warning reopen |
| SolidWorks 2024 COM 早绑定、数组封送和多轮廓拉伸经验 | cross-project tooling | `03_CrossProject/tooling.md` | written | reproducible HRESULTs and final successful build |
| SolidWorks API 工具入口 | map only | `06_Maps/tool-map.md` | written | new tooling entry |

## Next

- 用真实机械臂运动包络做干涉和倾覆检查。
- 用真实雷达高度确认 `30 mm` 净高。
- 用实物复测三块板的孔径、接插件方向和线束弯曲半径。
- 用真实风机入口、滤网和密封条完善气路。
- 替换轮/电机包络件并完成最终装配孔、螺母槽和打印公差。
