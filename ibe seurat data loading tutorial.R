library(Seurat)

#To load 10x genomics  matrices file
seurat_mtx <- Read10X(data.dir = "folder path")
seurat_mtx

#To load 10x genomics .h5 files
seurat_h5 <- Read10X_h5(filename = "file path")
seurat_h5

#Geo data text file loading
geo_data <- read.table("text file loading")
txtfileseurat <- CreateSeuratObject(counts = geo_data)
txtfileseurat

# CSV file loading
load_csv <- read.csv("file path")
load_csv

#Seurat object file , pre analysed file loading
seurat_objectfile <- readRDS(file = "File path")
seurat_objectfile