---
title: "[Data & Code] A drone imagery dataset for semantic segmentation of urban garden ground covers in biodiversity studies"
author: Drone Pag
date: '2026-04-08'
slug: uav-rgb-orthomosaics-urban-garden-biodiversity
categories:
  - data
tags: [Drone RGB imagery, Orthomosaics, Semantic segmentation, Urban biodiversity, Ground cover, Deep learning, Urban gardens]
subtitle: ''
summary: "A high-resolution UAV RGB imagery dataset for semantic segmentation of ground covers in urban community gardens — 24 orthomosaics across five gardens in Munich (2021–2022), manually annotated into eight ground-cover classes, with Train/Val/Test splits and a patch-based version for deep learning."
authors: [Yasamin Afrasiabian, Chenghao Lu, Anirudh Belwalkar, Hany Elsharawy, Xiaoxin Song, Ying Yuan, Fei Wu, Xiang Su, Elisa Van Cleemput, Monika Egerer, Kang Yu]

lastmod: '2026-06-17T09:00:00Z'
featured: no
draft: false
url_dataset: 'https://doi.org/10.5281/zenodo.18757882'
url_code: 'https://github.com/paglab/ugc-mapping'
image:
  filename: 'Fig6_GroundCovermasks.webp'
  caption: 'Visual comparison of ground-cover semantic segmentation on test-set orthomosaics: RGB tile, eight-class label mask, and the DeepLabV3+ prediction.'
  focal_point: ''
  preview_only: no
projects: []
related_content:
  publications: ["afrasiabian-2026-sd-drone"]
---

This dataset accompanies the Data Descriptor published in *Scientific Data* by [**Afrasiabian et al. (2026)**](/publication/afrasiabian-2026-sd-drone/), providing a high-resolution benchmark for mapping the fine-scale ground-cover heterogeneity of urban community gardens.

Urban gardens support city biodiversity through diverse ground covers that provide habitat, pollination, pest control, and soil functions — but their spatial heterogeneity has been poorly mapped due to a lack of high-resolution imagery. This dataset addresses that gap.


## What's in the dataset

- **24 RGB orthomosaics** (GeoTIFF) and their **24 pixel-level label masks**, collected in **2021–2022** at **five community gardens in Munich, Germany**
- Organised into **Train / Val / Test** splits (14 / 5 / 5 orthomosaics and masks)
- Spatial resolution **3.2–7.9 mm** per pixel (18.9–146.4 megapixels; EPSG:25832)
- **Eight ground-cover classes**: grass, herb, litter, soil, stone, straw, wood, and woodchip
- A **patch-based version** (cropped image/mask patches) ready for deep-learning pipelines
- A **metadata CSV** documenting per-image dimensions, resolution, CRS, and Agisoft processing/flight properties

## Benchmarks

The descriptor benchmarks both deep-learning (UNet, DeepLabV3+) and traditional machine-learning (Random Forest, XGBoost, Maximum Likelihood) classifiers. **DeepLabV3+** achieved the best performance, with an overall accuracy of ≈93.2% and an Intersection-over-Union of 69.4.

The dataset is intended to support research on **urban biodiversity, habitat modelling, garden management, and remote sensing**, and can be combined with other fine-scale datasets to advance sustainable urban green planning.

📦 **Dataset (Zenodo)**: <https://doi.org/10.5281/zenodo.18757882>

💻 **Code (GitHub)**: <https://github.com/paglab/ugc-mapping>

📄 **Citation**:

> Afrasiabian, Y., Lu, C., Belwalkar, A., Elsharawy, H., Song, X., Yuan, Y., Wu, F., Su, X., Van Cleemput, E., Egerer, M., & Yu, K. (2026). **A drone imagery dataset for semantic segmentation of urban garden ground covers in biodiversity studies**. *Scientific Data*, 13, 590. https://doi.org/10.1038/s41597-026-07152-z
