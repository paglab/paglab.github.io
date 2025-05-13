---
title: Weed instance segmentation from UAV Orthomosaic Images based on Deep Learning
date: '2025-01-01'
publication_types:
- '2'
authors:
- Chenghao Lu
- Klaus Gehring
- Stefan Kopfinger
- Heinz Bernhardt
- Michael Beck
- Simon Walther
- Thomas Ebertseder
- Mirjana Minceva
- Yuncai Hu
- Kang Yu
publication: Smart Agricultural Technology
doi: 10.1016/j.atech.2025.100966
url: ''
abstract: Weeds significantly impact agricultural production, and traditional weed
  control methods often harm soil health and environment. This study aimed to develop
  deep learning-based segmentation models in identifying weeds in potato fields captured
  by Unmanned Aerial Vehicle (UAV) orthophotos and to explore the effects of weeds
  on potato yield. Previous studies predominantly employed U-Net for weed segmentation,
  but its performance often declines under complex field environments and low-image
  resolution conditions. Some studies attempted to overcome this limitation by reducing
  flight altitude or using high-cost cameras, but these approaches are not always
  practical. To address these challenges, this study uniquely integrated Real-ESRGAN
  Super-Resolution (SR) for UAV image enhancement and the Segment Anything Model (SAM)
  for semi-automatic annotation. Subsequently, we trained the YOLOv8 and Mask R-CNN
  models for segmentation. Results showed that the detection accuracy mAP50 scores
  were 0.902 and 0.920 for YOLOv8 and Mask R-CNN, respectively. Real-ESRGAN reconstruction
  slightly improved accuracy. When multiple weed types were present, accuracy generally
  decreased. The YOLOv8 model characterized plant and weed coverage areas could explained
  41.2 \% of potato yield variations (R2 = 0.412, p-value = 0.01), underscoring the
  practical utility of UAV-based segmentation for yield estimation. Both YOLOv8 and
  Mask R-CNN achieved high accuracy, with YOLOv8 converging faster. While different
  nitrogen fertilizer treatments had no significant effect on yield, weed control
  treatments significantly impacted yield, highlighting the importance of precise
  weed mapping for spot-specific weed management. This study provides insights into
  weed segmentation using Deep Leaning and contributes to environmentally friendly
  precision weed control.
featured: no
projects: []
tags:
- Drone orthophotos
- Mask r-cnn
- Real-esrgan
- Segment anything model
- Super-resolution
- Weed segmentation
- Yolov8

---

Chenghao Lu, Klaus Gehring, Stefan Kopfinger, Heinz Bernhardt, Michael Beck, Simon Walther, Thomas Ebertseder, Mirjana Minceva, Yuncai Hu, & Kang Yu (2025). Weed instance segmentation from UAV Orthomosaic Images based on Deep Learning. *Smart Agricultural Technology*, 11: 100966.
