# Abacus AI Desktop Configuration Project

## Overview
This project is a structured approach to configuring Abacus AI Desktop to match my specific work style, preferences, and use cases. The goal is to create a personalized configuration that maximizes productivity and ensures the AI assistant behaves exactly as I need it to.

## Purpose
- Build a comprehensive, personalized configuration for Abacus AI Desktop
- Ensure the AI assistant understands my work patterns, preferences, and boundaries
- Create reusable workflows, tasks, snippets, and rules that align with how I work
- Document all decisions and configurations for future reference and updates

## User Profile Summary

*   **Primary Use Cases:**
    *   Immediate: Fixing/updating a cloned GitHub repo for a customer requirement.
    *   Ongoing: Planning, analysis, knowledge management, document creation.
    *   Future Interest: Automation.
*   **Current Tools:** Primarily Office products, various IDEs/AIs, diagramming tools, some database interaction (Hana), reporting/visualization (SAP Embedded Analytics), and automation (Power Automate).
*   **Assistant Role Preference:**
    1.  Planning/Decision Support
    2.  Automation
    3.  Writing/Documentation
    4.  Research/Summarization
    5.  Coding Partner
*   **Communication Style:**
    *   Concise answers, but with the ability to provide detail upon request.
    *   Neutral/professional tone.
*   **Strong Preferences/Boundaries:**
    *   Accuracy over speed; no assumptions or making things up.
    *   Use cases, samples and visuals are helpful.
    *   Precise edits: only change the specific item requested, not unrelated code/content.
    *   Clean lists for outputs.
    *   Clear, thought-out plans with tracked activities.
    *   Small, iterative work/updates.
    *   Don't change things outside the topic asked.
    *   Don't do extra work based on implied instructions.
    *   Don't write code that changes production systems without explicit approval.
*   **Data Sensitivity:** Internal but not highly sensitive company info.
*   **Integration Interest:** GitHub/Git repos (definite), Documentation (Confluence, Notion, etc.) (maybe), Other (maybe).

---

## TODO List

### Phase 1: Discovery & Design ✅ COMPLETED

#### 1.1 Define High-Level Configuration Areas ✅
- [x] Identify main configuration categories
- [x] Order categories logically
- [x] Create high-level checklist

**Output:** 8 main configuration areas identified

#### 1.2 User Profile Interview ✅
- [x] Conduct interview on work & goals
- [x] Gather style & preference information
- [x] Define data & safety boundaries
- [x] Identify systems to integrate

**Output:** User Profile Summary created

#### 1.3 Map Profile to Configuration Objects ✅
- [x] Design what should exist under each of the 8 areas
- [x] Tailor recommendations to user profile
- [x] Keep at "what to have" level (not "how to configure")

**Output:** Recommended Configuration Objects for all 8 areas

#### 1.4 Incorporate Behavioral Scenarios ✅
- [x] Add batch processing rules (Scenario 1: 40 rows without stops)
- [x] Add restatement vs. expansion rules (Scenario 2: confirm without adding)
- [x] Update relevant sections (Rules, Workflows, Tasks, Snippets, Global Checks)

### Phase 2: Deep Dive Implementation 🔄 IN PROGRESS

### PHASE 2.1:COMMISSION-XML FOCUS

1. Extensions
- [X] XML Tools (Line 103): Essential. You are parsing complex SAP Commissions XML (v33.0). You will need this to validate, format, and inspect the structure of the input files you are testing against.
- [X] Markdown Extensions (Lines 105-106): You are heavily using .md files (TODO_XML.md, DEV_NOTES.md, README.md) to track this modernization project. These extensions will help you render and edit your project tracking documents.
- [X] VBA Support: Your config list misses VBA. Since the core code is in SAP-Commissions-XML.xlsm, you should add a VBA extension (like VSCode VBA or XVBA) if you plan to export code to text files for version control.

2. Rules & Safety (Section 2.1) - High Priority
This project has a strict data privacy requirement (no customer XML in repo).
- [X] Scope limitation rules (Line 83): Configure a rule to never read, commit, or suggest committing .xml files that are not explicitly part of the repo structure.
- [X] Data Sensitivity: Define a rule that treating *.xml files (other than config files) as potential "Customer Data" that must remain local.
  
3. Workflows (Section 2.5)
- [ ] Design code update/fix workflow (Line 126): You need a specific workflow for VBA. Since you cannot edit .xlsm binaries directly in the IDE:
Workflow Goal: How to safely digest user-provided VBA snippets -> apply them in Excel -> export back to repo for tracking.

4. Tasks (Section 2.6)
- [ ] Create code explanation task template (Line 133): Useful for legacy VBA. You might need me to explain what a specific parser subroutine does before we modernize it.


#### 2.1 Rules (Behavior & Guardrails) ⏳ IN PROGRESS
- [ ] Encode Desktop-Specific Knowledge
- [ ] Automate Desktop-Specific Workflows
- [ ] Standardize Desktop Interactions & Automation
- [ ] Customize Language & Tone for Desktop Context
- [ ] Add Personal Desktop Style Preferences
- [ ] Accuracy/Fact-checking rules
- [x] Scope limitation rules - **CREATED**: Rule to never read, commit, or suggest committing .xml files that are not explicitly part of the repo structure
- [x] Data Sensitivity - **CREATED**: Rule treating *.xml files (other than config files) as potential "Customer Data" that must remain local
- [ ] Production system interaction rules
- [ ] Output formatting rules
- [ ] Iterative work rules
- [ ] Are these crated inside a project on in general as part of abacus, and then you decide which to add to a project?  And if in project if project is deleted to they go away or are they re-usable?
- [ ] valid options for rule type?  I see Always, and auto-attached as examples.  anything else?
- [ ] what about the globs setting?  I see that it can be a wildcard of, or an extension, anything else?
- [ ] Matrix of when to apply and when not to?  And ones that do not interact?

- [ ] Review: globs used, 

#### 2.2 Core Editor & Environment Setup ⏳ NOT STARTED
- [ ] Editor behavior settings (tabs vs spaces, tab size, auto‑save, word wrap, line numbers)
- [ ] Language / formatting defaults (default formatter, linting on save, code style presets)
- [ ] Document final editor configuration

#### 2.3 Extensions (Plugins / Integrations) ⏳ IN PROGRESS
- [x] Identify needed language support extensions
	- [x] Python (if needed for any scripting)
	- [x] YAML (for configuration files)
	- [x] XML Tools - **RECOMMENDATION UPDATED**: Use "XML" extension by Red Hat instead, which is more feature-rich and actively maintained
	- [ ] VBA - **NEW**: Add VBA extension by SpencerRP for VBA development support
- [x] Identify documentation/Markdown extensions
	- [x] Markdown All in One - **KEEP THIS ONE**
	- [x] Markdown Preview Enhanced - **REMOVE THIS ONE** (redundant with Markdown All in One)
	- [ ] Docs Authoring Pack
	- [ ] markitdown
	- [ ] Markdown Preview Mermaid Support - **KEEP THIS ONE** (specifically for Mermaid diagrams)
- [x] Identify planning/diagramming extensions
	- [x] Draw.io Integration
	- [x] PlantUML
	- [x] Mermaid Markdown Syntax Support
- [x] Identify AI-specific helper extensions
	- [x] Todo Tree
	- [x] Bookmarks
- [ ] Document final extension list with rationale

#### 2.4 MCPs (Model Context Protocol Servers / External Tools) ⏳ NOT STARTED
- [ ] GitHub
- [ ] Google Drive
- [ ] Power Automate
- [ ] Document final MCP configurations

#### 2.5 Workflows (Multi‑Step Automation) ⏳ NOT STARTED
- [ ] Design repo analysis workflow
- [ ] Design code update/fix workflow
- [ ] Design document generation workflow
- [ ] Design knowledge extraction workflow
- [ ] Design planning support workflow
- [ ] Document final workflows

#### 2.6 Tasks (Units of Work / Prompts) ⏳ NOT STARTED
- [ ] Create code explanation task template
- [ ] Create code refactoring task template
- [ ] Create documentation drafting task template
- [ ] Create summarization task template
- [ ] Document final task templates

#### 2.7 Snippets (Reusable Text / Prompt Blocks) ⏳ NOT STARTED
- [ ] Create context snippets
- [ ] Create instruction snippets
- [ ] Create code template snippets
- [ ] Create documentation boilerplate snippets
- [ ] Create full execution snippet
- [ ] Create exact restatement snippet
- [ ] Create scope adherence snippet
- [ ] Assign triggers/shortcuts to snippets
- [ ] Document final snippets

#### 2.8 Global Quality & Safety Checks ⏳ NOT STARTED
- [ ] Run a small **end‑to‑end test**:
	- [ ] Use a workflow.  
	- [ ] Call an MCP (if relevant).  
	- [ ] Use a snippet + task template.  
	- [ ] Confirm results match your expectations.
- [ ] Document final quality & safety checks

---

### Phase 3: Testing & Refinement ⏳ Not Planned

#### 3.1 Initial Testing
- [ ] Test all workflows with real scenarios
- [ ] Test all task templates
- [ ] Test all snippets
- [ ] Verify rules are being followed
- [ ] Test MCP connections and permissions

#### 3.2 Refinement
- [ ] Document any issues found during testing
- [ ] Adjust configurations based on test results
- [ ] Re-test problem areas
- [ ] Update config guide with final versions

#### 3.3 Real-World Validation
- [ ] Use configuration for actual work tasks
- [ ] Track any friction points or unexpected behaviors
- [ ] Make iterative improvements
- [ ] Update documentation

---

### Phase 4: Maintenance ⏳ ONGOING (Not Planned)

#### 4.1 Regular Reviews
- [ ] Schedule periodic configuration reviews (suggest quarterly)
- [ ] Review rules for effectiveness
- [ ] Review workflows for efficiency
- [ ] Update extensions as needed
- [ ] Adjust MCPs based on new integration needs

#### 4.2 Continuous Improvement
- [ ] Log new use cases as they arise
- [ ] Add new workflows/tasks/snippets as needed
- [ ] Refine existing configurations based on experience
- [ ] Keep documentation up-to-date

---

### Quick Status Summary

**Completed:** Phase 1 (Discovery & Design)  
**Current Focus:** Phase 2.1 (Rules Deep Dive) - Ready to start  
**Next Up:** Phase 2.2 through 2.8 (remaining deep dives)  
**Blocked:** None  
**Notes:** Ready to begin deep dive interviews. Start with Rules section.
