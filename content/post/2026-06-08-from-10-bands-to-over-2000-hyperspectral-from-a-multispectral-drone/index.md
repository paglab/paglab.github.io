---
title: 'From 10 Bands to Over 2000: Hyperspectral Crop Sensing from a Multispectral Drone'
subtitle: 'A physics-guided deep learning framework, M2H-SWIR, reconstructs full hyperspectral reflectance — including the nitrogen-sensitive shortwave infrared — from everyday UAV multispectral cameras.'
summary: 'Hyperspectral sensors see crop nitrogen in detail but are expensive; multispectral drones are cheap but spectrally coarse. Our new M2H-SWIR framework bridges the gap, reconstructing continuous 400–2500 nm reflectance from a 10-band UAV camera and improving nitrogen estimation in winter wheat.'
authors:
- admin
tags:
- Precision Agriculture
- Hyperspectral
- UAV
- Deep Learning
- Crop Nitrogen Management
- Radiative Transfer
- PROSAIL
- SWIR
- Remote Sensing
- Winter Wheat
categories:
- paper
- news
date: '2026-06-08T09:00:00Z'
lastmod: '2026-06-08T09:00:00Z'
featured: true
draft: false

image:
  filename: 'images/wang2026jag-ga.png'
  caption: 'M2H-SWIR reconstructs continuous hyperspectral reflectance (400–2500 nm) from a 10-band UAV multispectral image for crop nitrogen monitoring.'
  focal_point: 'Smart'
  preview_only: false

projects: []
---

What if an everyday (low-cost) drone multispectral camera could see almost as much as a research-grade hyperspectral sensor? In a new study published in the *International Journal of Applied Earth Observation and Geoinformation*, [**Jie Wang**](/author/jie-wang/), [**Anirudh Belwalkar**](/author/dr.-anirudh-belwalkar/), and [**Kang Yu**](/author/prof.-dr.-kang-yu/), together with collaborators, show how to get there — turning **10 broad bands into over 2000 continuous narrow bands**.

📄 Read the paper: [**Wang et al. (2026)**](/publication/wang-2026-ijaeog-uav), *Int. J. Appl. Earth Obs. Geoinf.*, 150, 105364.

## Why it matters

Knowing how much nitrogen a crop holds is central to **precision fertilization, higher yields, and less waste**. Hyperspectral sensors capture the fine spectral detail that reveals nitrogen status — but they are costly and operationally complex, which keeps them out of most farms and field trials.

Multispectral UAV cameras are the opposite: **affordable and everywhere**, but they record only a handful of broad bands. Crucially, they miss the **shortwave infrared (SWIR)** region, where some of the most informative nitrogen-sensitive features live.

## What we did

We built **M2H-SWIR** — a framework that pairs **physics with deep learning** to reconstruct continuous hyperspectral reflectance (400–2500 nm) from ordinary UAV multispectral imagery. It brings together:

- 🌱 **Physics-based canopy simulation** with the PROSAIL-PRO radiative transfer model;
- 🧠 **Deep neural networks** that learn the multispectral-to-hyperspectral mapping;
- 🔦 **Explicit reconstruction of the SWIR**, recovering nitrogen-sensitive absorption features the camera never measured directly;
- 🌾 **Field validation** against spectrometer measurements in winter wheat experiments.

## Key findings

- A 10-band UAV image can be expanded into **continuous reflectance across the visible, near-infrared, and SWIR**;
- M2H-SWIR **outperformed conventional radiative-transfer inversion** approaches;
- The reconstructed spectra **preserved the nitrogen-sensitive absorption features** that matter for crop diagnostics;
- Nitrogen estimates from the reconstructed hyperspectral data were **more accurate than those from the raw multispectral bands**.

## Looking forward

M2H-SWIR points toward **affordable hyperspectral monitoring**: the spectral richness of a lab-grade sensor, from hardware many groups already fly. We hope it lowers the barrier to high-quality crop nutrient sensing in research and practice alike.

The code is **open source**, and we warmly invite others to test the framework on independent datasets, other crops, and different sensors. The study was based on the MicaSense Dual-camera system, but the framework should be applicable to other multispectral cameras. 

🔗 **Paper:** <https://doi.org/10.1016/j.jag.2026.105364>
💻 **Code:** <https://github.com/windying123/M2H-SWIR>

*Congratulations to [Jie Wang](/author/jie-wang/) and co-authors — Anirudh Belwalkar, Sebastian T. Meyer, Fei Li, Itai Herrmann, and Kang Yu.*

*— TUM Precision Agriculture Lab*
