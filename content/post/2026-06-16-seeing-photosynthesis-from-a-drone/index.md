---
title: 'Seeing Photosynthesis from a Drone: Physics-Informed AI for Wheat'
subtitle: 'Combining PROSAIL physics, vegetation indices, and a Vision Transformer to predict photosynthetic traits, biomass, and yield in winter wheat from UAV multispectral imagery.'
summary: 'Photosynthetic traits are slow to measure by hand. In a new European Journal of Agronomy paper, we link UAV multispectral imagery to leaf physiology with a physics-informed machine learning framework — predicting CO₂ assimilation, stomatal conductance, photosystem II efficiency, biomass, and grain yield across winter wheat varieties.'
authors:
- admin
tags:
- Precision Agriculture
- UAV
- Deep Learning
- Vision Transformer
- Physics-Informed Machine Learning
- PROSAIL
- Photosynthesis
- High-Throughput Phenotyping
- Winter Wheat
- Yield Prediction
categories:
- paper
- news
date: '2026-06-16T09:00:00Z'
lastmod: '2026-06-16T09:00:00Z'
featured: true
draft: false

image:
  filename: 'images/zhang2026eja-ga.jpg'
  caption: 'A physics-informed spatial learning framework links UAV multispectral imagery to leaf-level traits, producing pixel-wise maps of photosynthesis, biomass, and yield in winter wheat.'
  focal_point: 'Smart'
  preview_only: false

projects: []
---

Photosynthesis drives crop growth and yield — yet measuring it in the field is slow, hands-on work, one leaf at a time. Can a drone do it instead? In a new study in the *European Journal of Agronomy*, [**Jingcheng Zhang**](/author/jingcheng-zhang/) and [**Kang Yu**](/author/prof.-dr.-kang-yu/) show how **plant canopy-light interaction physics + AI + UAV imaging** can read wheat physiology from the sky.

📄 Read the paper: [**Zhang & Yu (2026)**](/publication/zhang-2026-eja-physicsinformed), *Eur. J. Agron.*, 180, 128202.

## Why it matters

Drone imagery is fast and covers many plots at once — ideal for breeding trials. But there's a gap to bridge: cameras measure **canopy reflectance**, while photosynthesis is a **physiological process** happening inside leaves. Turning pixels into biology requires models that respect both.

## What we did

We built a **physics-informed machine learning framework** to predict five key wheat traits from UAV multispectral (MicaSense) imagery: **CO₂ assimilation rate, stomatal conductance, photosystem II efficiency, aboveground biomass, and grain yield**. It combines:

- 📊 **Vegetation indices and texture features** from the multispectral images;
- 🌿 **PROSAIL radiative transfer inversion**, adding physics-based plant variables (e.g., chlorophyll, leaf area);
- 🤖 **Spatial deep learning** — a 2D-CNN and a **Vision Transformer (ViT)** that learn directly from image patches;
- 🎯 **Multi-output learning** to predict several related traits together.

## Key findings

- UAV imagery can predict **not only biomass and yield, but also harder-to-measure photosynthetic traits**;
- **PROSAIL-derived parameters add real value** beyond standard vegetation indices;
- The **Vision Transformer** learned meaningful spatial patterns and performed strongly for **yield prediction**;
- Pairing **physics with deep learning improved transferability across wheat varieties** in several cases;
- **Random Forest** remained a robust baseline when generalizing to unseen varieties.

## Looking forward

This work shows how **plant canopy-light interaction physics, machine learning, and UAV imaging** together can make field phenotyping far more scalable — screening crop performance across many plots instead of a few plants by hand. We hope it supports **high-throughput wheat phenotyping** and future breeding aimed at photosynthesis, biomass, and yield. 

🔗 **Paper:** <https://doi.org/10.1016/j.eja.2026.128202>

*Congratulations to [Jingcheng Zhang](/author/jingcheng-zhang/) and [Kang Yu](/author/prof.-dr.-kang-yu/).*

*— TUM Precision Agriculture Lab*
