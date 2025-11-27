#!/usr/bin/bash
# ======================================================
# Create directories for NBI game dynamically
# ======================================================

# Define all paths
map=(
  "/norwich/nbi/jic/floor_1/reception"
  "/norwich/nbi/jic/floor_1/microscope_room"
  "/norwich/nbi/jic/floor_1/toilet"
  "/norwich/nbi/jic/floor_2/metabolomics_lab"
  "/norwich/nbi/jic/floor_2/informatics_office"
  "/norwich/nbi/jic/floor_2/toilet"

  "/norwich/nbi/tsl/floor_1/proteomics_lab"
  "/norwich/nbi/tsl/floor_1/toilet"
  "/norwich/nbi/tsl/floor_2/synbio_lab"
  "/norwich/nbi/tsl/floor_2/toilet"

  "/norwich/nbi/qib/floor_1/reception"
  "/norwich/nbi/qib/floor_1/tier_3_lab"
  "/norwich/nbi/qib/floor_1/toilet"
  "/norwich/nbi/qib/floor_2/gut_model_lab"
  "/norwich/nbi/qib/floor_2/meeting_room"
  "/norwich/nbi/qib/floor_2/toilet"

  "/norwich/nbi/ei/floor_1/server_room"
  "/norwich/nbi/ei/floor_1/toilet"
  "/norwich/nbi/ei/floor_1/biofoundry_lab"
  "/norwich/nbi/ei/floor_2/genomics_lab"
  "/norwich/nbi/ei/floor_2/toilet"
)

# Loop through each path and create it
for dir in "${map[@]}"; do
  mkdir -p "$dir"
done

echo "All directories created successfully!"
