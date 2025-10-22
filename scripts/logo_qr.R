# install.packages(c("qrencoder", "magick"))
library(qrencoder)
library(magick)

# ---- paths ----
qr_base   <- "static/images/paglab_qr_base.png"
qr_final  <- "static/images/paglab_qr.png"
logo_path <- "assets/media/logo_old.png"

# ensure output folder exists
dir.create("static/images", recursive = TRUE, showWarnings = FALSE)

# 1️⃣ Generate QR matrix
qr_matrix <- qrencoder::qrencode("https://paglab.org")

# 2️⃣ Save QR code as PNG (simple black/white)
png(qr_base, width = 800, height = 800)
par(mar = c(0, 0, 0, 0))
image(t(apply(qr_matrix, 2, rev)), col = c("white", "black"), axes = FALSE)
dev.off()

# 3️⃣ Read the QR and logo
qr_img   <- image_read(qr_base)
logo_img <- image_read(logo_path)

# 4️⃣ Resize logo to about 20–25% of QR width
qr_info <- image_info(qr_img)
target_logo_w <- round(qr_info$width * 0.22)
logo_resized  <- image_resize(logo_img, paste0(target_logo_w, "x"))

# 5️⃣ Center the logo automatically
logo_info <- image_info(logo_resized)
offset_x  <- round((qr_info$width  - logo_info$width)  / 2)
offset_y  <- round((qr_info$height - logo_info$height) / 2)
final_qr  <- image_composite(qr_img, logo_resized, offset = paste0("+", offset_x, "+", offset_y))

# 6️⃣ Save final QR image
image_write(final_qr, path = qr_final)

message("✅ Final QR saved at: ", qr_final)