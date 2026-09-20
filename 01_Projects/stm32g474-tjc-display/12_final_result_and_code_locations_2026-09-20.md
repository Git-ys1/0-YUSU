# 赛后结果与最终代码定位（2026-09-20）

## 最终结果

| 项目 | 结论 |
|---|---|
| 赛事 | 2026 年北京市大学生电子设计竞赛 |
| 参赛编号 | `B26244` |
| 赛题 | G 题 |
| 学校 | 北京交通大学 |
| 获奖等级 | **二等奖（省级）** |
| 证据 | `F:\AcademicHub\000资料相关\电赛\2026TI杯\2026年北京市大学生电子设计竞赛获奖名单.xlsx`，`Sheet1` 第 142 行 |

## 代码位置结论

| 角色 | 路径 | 状态 |
|---|---|---|
| 最终比赛代码真源 | `F:\Project\stm32G474VETx\TI\G_Periodic_Signal_Analyzer\teammate\24` | 2026-08-01现场最终整合工程；赛后统一从代码仓库查看 |
| 最终代码原始备份 | `F:\AcademicHub\000资料相关\电赛\2026TI杯\24` | 与仓库真源全树一致，只作收到时证据，不继续开发 |
| 最终代码原包 | `F:\AcademicHub\000资料相关\电赛\2026TI杯\24.zip` | SHA-256：`9E21EB8435983B9AC42F2F062F7BB256D01035A653957155E30D31DDC83213E5` |
| 整理后的开发主线 | `F:\Project\stm32G474VETx\TI\G_Periodic_Signal_Analyzer\firmware` | 后续维护入口；不是现场最终`24`包的逐字副本 |
| 队友原始底座 | `F:\Project\stm32G474VETx\TI\G_Periodic_Signal_Analyzer\teammate\current` | 与`teammate\last`源码一致，早于最终整合的`24` |
| Git仓库根目录 | `F:\Project\stm32G474VETx\TI` | Git提交、标签和发布入口 |

## 版本判断依据

- 外部`24`与仓库`teammate\24`的346个文件、56,045,062字节逐文件SHA-256完全一致。
- `24`相对`teammate\current`更新了`main.c`以及桥接/显示相关文件；因此队友原始底座不是最终现场版本。
- `24`与`firmware`的`analyzer_bridge.c`、`display.c`一致，但`main.c`不同；`firmware`保留了重构和本地测试入口，不能冒充最终提交包。
- Git远端当前发布基线仍是`v2.6.0`；本地`main`领先远端1个提交且工作树存在未提交的V2.8.1、报告和文档整理改动，因此仓库发布尚未收尾。

## 恢复工作时怎么选

1. 回看、复现实赛版本：从仓库`teammate\24`复制到临时目录构建。
2. 继续整理和开发：进入Git工作区的`firmware`，先以`24`做差异审计。
3. 查看队友未融合的原始结构：打开`teammate\current`。
4. 从比赛资料入口进入时：先读`F:\AcademicHub\000资料相关\电赛\2026TI杯\README.md`，再跳转代码仓库。

## Memory Routing Audit

- 获奖结果、最终代码位置和版本判断属于本项目长期事实，保存在项目知识库。
- 项目地图同步改为已完成，并记录省二等奖。
- 未写入全局偏好或跨项目规则。
