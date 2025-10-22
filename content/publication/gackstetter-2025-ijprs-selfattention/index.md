---
title: Self-attention and frequency-augmentation for unsupervised domain adaptation
  in satellite image-based time series classification
date: '2025-01-01'
publication_types:
- '2'
authors:
- David Gackstetter
- Kang Yu
- Marco Körner
publication: ISPRS Journal of Photogrammetry and Remote Sensing
doi: 10.1016/j.isprsjprs.2025.03.024
url: ''
abstract: With the increasing availability of Earth observation data in recent years,
  the development of deep learning algorithms for the classification of satellite
  image time series (SITS) has substantially progressed. Yet, when encountering settings
  of lacking target labels and distinct feature variations, even the latest classification
  algorithms may perform poorly in transferring knowledge from a trained dataset to
  an unknown target dataset, despite similar or even identical label sets. The research
  field of unsupervised domain adaptation (UDA) focuses on methods to overcome these
  challenges by providing algorithms that explicitly learn domain shifts between different
  data domains in the absence of target-labeled data. Building upon recent advances
  on generic UDA research in time series settings, we propose RAINCOAT-SRS, an enhancement
  of the frequency-augmented UDA-algorithm RAINCOAT specifically for the SITS domain.
  To evaluate the default and adjusted model variants, we designed several closed-label
  set, cross-regional and multi-temporal crop type mapping experiments, which represent
  common sub-problems of UDA in SITS. We first benchmark RAINCOAT against TimeMatch
  as a leading algorithm in this application context. Subsequently, we explored different
  encoder-to-decoder constellations as architectural enhancements. These analyses
  revealed that a combination of an self-attention-based encoder with the default
  decoder yields a performance increase to the standard algorithm of up to 6 \% in
  average f1-score, and to TimeMatch by up to 24 \%. Beyond, we assessed the impact
  of the frequency feature and SITS-specific feature extensions by integrating weather
  data, which both showed to improve classification accuracy only in individual sub-experiments
  however not consistently across the entire scope of scenarios. Finally, we outline
  key factors influencing the transferability, thereby emphasizing the major importance
  of domain-overarching stability of class-relative, structural patterns rather than
  of collective, linear shifts between domains. Through this research, we introduce
  RAINCOAT-SRS, a novel model for UDA in SITS, designed to advance generalization
  in remote sensing by enabling more comprehensive cross-regional and multi-temporal
  SITS experiments in face of lacking target-labeled data.

---

David Gackstetter, Kang Yu, & Marco Körner (2025). Self-attention and frequency-augmentation for unsupervised domain adaptation in satellite image-based time series classification. *ISPRS Journal of Photogrammetry and Remote Sensing*, 224: 113--132.
