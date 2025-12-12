---
title: "Workflows Workshop Home"
subtitle: "Learn how to write semi-automated stock assessment reports!"
page-layout: full
---

<img src="assets/workshop_banner.png" align="center" width="430" height="115"/>

This repository houses the agenda, materials, and communication for the NOAA Fisheries Stock Assessment Workflows Workshops being held starting in 2026! Please use this README to help navigate within our repository and find out our current progress and plans in real time.

::: {.callout-warning}
## Workshop preparation is in progress!

Currently, we are coordinating with our NOAA Fisheries Regional Science Centers to determine the best time to work with our stock assessment scientists and conduct these trainings.
:::


# Background

The workflows of stock assessment scientists across the U.S. are highly variable and all consistently face similar issues including lack of automation, challenging data wrangling, increased requests for analyses, and more. A team with the National Stock Assessment Program at NOAA Fisheries HQ set about addressing some of these needs by identifying parts of the workflow scientists needed help in. While there were needs to improve parts of the workflow at every step, the team and a steering committee decided to first approach the lowest hanging fruit, reporting. The goal of this project was to establish a semi-automated system for generating reports in order to reduce time completing mundane and tedious tasks that, with some effort, could be automated. From there, [`asar`](https://github.com/nmfs-ost/asar) and [`stockplotr`](https://github.com/nmfs-ost/stockplotr) were built along with beginning to establish a standard set of guidelines for stock assessment reports.

# Expected setup before workshop

Before attending the workshop, we ask that you take the following steps:

1. Set up a local RStudio project linked with a GitHub repository (explained in the ["How to set up a local session" page](resources/local_session_info.qmd).
2. Ensure that you can run R code with a platform like RStudio, VS Code, Positron, etc.
3. Ensure you can create [Quarto documents](https://quarto.org/docs/get-started/)
4. Install `pak`, `asar`, `stockplotr`, and `tinytex` as explained in the [Day 1 curriculum](@sec-install).

# System Requirements

| Program | Version |
|---------|---------|
| <img src="https://cdn.jsdelivr.net/gh/devicons/devicon@latest/icons/rstudio/rstudio-original.svg" alt="Rstudio" width="55" height="55"/> | [R](https://www.r-project.org/) |
| <img src="https://rstudio.github.io/cheatsheets/html/images/logo-quarto.png" alt="Quarto" width="50" height="55"/> | [Quarto](https://quarto.org/docs/get-started/) version 1.6+ |
| <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/9/92/LaTeX_logo.svg/1200px-LaTeX_logo.svg.png" alt="LaTeX" width="135" height="55"/> | [Latex](https://latex3.github.io/) from [TinyTeX-2 bundle](https://github.com/rstudio/tinytex-releases?tab=readme-ov-file#releases) |

# Navigation

## Curriculum

The curriculum is comprised of three days of tutorial-based materials (see the left sidebar for [Day 1](https://nmfs-ost.github.io/workflows-workshop/Curriculum/Day_1/day_1.html), [Day 2](https://nmfs-ost.github.io/workflows-workshop/Curriculum/Day_2/day_2.html), and [Day 3](https://nmfs-ost.github.io/workflows-workshop/Curriculum/Day_3/day_3.html) links). We have dedicated a lot of time to the documentation of `asar` and `stockplotr`, so we encourage everyone to visit these sites prior to the workshop.

## Example

The "examples" folder contains multiple examples of reports produced from `asar` and `stockplotr` with varying complexities. Feel free to explore these folders and familiarize yourself with the contents generated from these two packages.

# Format

As of now, we are planning to hold a series of workshops spanning 3 days (Tuesday-Thursday) in 3 hours sessions. 

[Day 1](https://nmfs-ost.github.io/workflows-workshop/Curriculum/Day_1/day_1.html): Learning the foundations of Markdown, Quarto, and the Workflow

  - Markdown
  - Quarto
  - General overview of {asar} and {stockplotr}

[Day 2](https://nmfs-ost.github.io/workflows-workshop/Curriculum/Day_2/day_2.html): Introduction to `asar`

  - Basics of {asar}
  - Getting familiar
  - Customization and adding complexities to your report

[Day 3](https://nmfs-ost.github.io/workflows-workshop/Curriculum/Day_3/day_3.html): Adding Complexity and `stockplotr`

  - Introduction to {stockplotr}
  - Integrating tables and figures into {asar} report
  - Making reports accessible

# The organizers

These workshops are being organized and taught by Workflows team members Sam Schiano and Sophie Breitbart, both of whom are based in OST.
