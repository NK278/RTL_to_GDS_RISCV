<p align="center">
  <img src="https://img.shields.io/badge/RTL_to_GDSII-RISC--V%20Physical%20Design-blueviolet?style=for-the-badge&logo=riscv" />
</p>

<h1 align="center">RTL_to_GDS_RISCV</h1>
<h3 align="center">Complete RTL → GDSII Physical Design of a 32-bit RISC-V Core using Cadence Tools</h3>

<p align="center">
  <img src="https://img.shields.io/badge/RISC--V-ISA-blue?style=for-the-badge&logo=riscv" />
  <img src="https://img.shields.io/badge/Cadence-Innovus%20%7C%20Genus%20%7C%20Tempus-red?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Physical%20Design-CTS%2C%20STA%2C%20Routing-green?style=for-the-badge" />
  <img src="https://img.shields.io/badge/GDSII-Signoff-success?style=for-the-badge" />
</p>

---

# 📌 Overview

This repository documents the **full backend implementation** of a 32-bit RISC-V processor, taken from clean RTL to final **GDSII**, using the **Cadence Digital Backend Flow**:

- **Genus** – Synthesis  
- **Innovus** – Floorplan, Placement, CTS, Routing  
- **Tempus** – Timing Signoff  
- **Voltus** – Power Analysis 

A major contribution of this project is the implementation of a **post-CTS redundant clock buffer reduction algorithm**, achieving lower clock power and reduced area while still meeting all timing constraints across multiple PVT corners.

---

# 🚀 Key Outcomes

- ✅ Full RTL → GDS flow completed  
- ✅ Multi-corner STA (FF/TT/SS at 1.05V, 125°C)  
- ✅ ~10% **Clock Power Reduction**  
- ✅ ~1.5–2% **Area Reduction**  
- ✅ No new timing violations  
- ✅ Final GDS successfully generated (`rtl_module.gds`)

---

# 🧠 RISC-V Core Architecture

The processor RTL includes:

- `ALU.v` – Arithmetic Logic Unit  
- `DATAPATH.v` – Pipeline datapath  
- `CONTROL.v` – Control logic  
- `IFU.v` – Instruction Fetch Unit  
- `INST_MEM.v` – Instruction Memory  

Modular, simple, clean RTL ideal for backend experimentation.

---

# 📁 Repository Structure

```text
RTL_to_GDS_RISCV/
│
├── ALU.v
├── CONTROL.v
├── DATAPATH.v
├── IFU.v
├── INST_MEM.v
│   └── # RTL modules
│
├── design.sdc
├── STA*.tcl
├── STA_bc.tcl / STA_wc.tcl
│   └── Static Timing scripts
│
├── place_and_route/
├── physical_design/
├── PostRoutingPowerRpt/
│   └── PnR and power reports
│
├── bc_optimized.v
├── bc_optimizedd.v
│   └── Clock-optimized netlists
│
├── rtl_module.gds
├── rtl_module.rpt
│   └── Final GDS + timing/area summary
│
├── reports_script/
├── sta_after_synthesis/
├── sta_after_synthesis_bc/
├── sta_after_synthesis_wc/
│   └── Multi-corner STA reports
│
├── output/
└── slow.lib
````

---

# 🌳 Clock Buffer Reduction — Main Contribution

Clock Tree Synthesis (CTS) inserts many buffers/inverters to fix:

* Slew
* Skew
* Latency
* Fan-out

However, after routing, many buffers become **redundant**.

A buffer was removed only if:

### ✔ Slew remained within target

### ✔ Load was still drivable

### ✔ No setup/hold violations appeared

### ✔ Clock skew stayed within constraints

### ✔ Valid across FF/TT/SS corners

This selective removal leads to:

* Lower **clock dynamic power**
* Lower **cell area**
* Cleaner clock topology

---

# 📊 **Charts & Analysis**


---

## **Area Comparison (Before vs After)**

<img width="849" height="502" alt="image" src="https://github.com/user-attachments/assets/2cfc8f58-106a-4dfa-8208-f0f0340c7b76" />


---

## **Clock Power Comparison (Before vs After)**

<img width="841" height="502" alt="image" src="https://github.com/user-attachments/assets/dc207947-dc09-481e-ac23-913ec980708e" />


---

## **Corner-wise Summary Table**

| Corner | Area Before (µm²) | Area After (µm²) | Power Before (mW) | Power After (mW) |
| ------ | ----------------- | ---------------- | ----------------- | ---------------- |
| FF     | 18796             | 18509            | 2.653             | 2.418            |
| TT     | 19327             | 19032            | 2.670             | 2.435            |
| SS     | 19687             | 19411            | 2.695             | 2.459            |

---


# ⚠️ Reproducibility Disclaimer

This repository does **not** include:

* Cadence tool scripts
* PDKs / LEFs / LIBs
* Innovus databases
* Actual run directories

These cannot be shared publicly due to **Cadence licensing restrictions**.

The repo serves as a **documentation + reference project**.

---


