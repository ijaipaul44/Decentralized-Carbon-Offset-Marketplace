# Decentralized Carbon Offset Marketplace

A blockchain-based system for managing carbon offset projects, verifications, trading, and retirements using Clarity smart contracts on the Stacks blockchain.

## Overview

This system provides a comprehensive solution for carbon offset management with the following components:

- Project Registration: Record and manage carbon reduction initiatives
- Offset Verification: Validate the effectiveness of carbon reduction projects
- Trading: Facilitate buying and selling of carbon offset credits
- Retirement: Manage the permanent removal of used offset credits

## Contracts

### Project Registration Contract

The Project Registration Contract (`project-registration.clar`) manages the creation and lifecycle of carbon reduction projects:

- Register new projects with detailed information
- Update project status and details
- Retrieve project information

```clarity
;; Example: Register a new project
(contract-call? .project-registration register-project 
  "Reforestation Project"
  "Amazon Rainforest"
  "Forestry"
  u10000
  u1625097600
  u1656633600)

