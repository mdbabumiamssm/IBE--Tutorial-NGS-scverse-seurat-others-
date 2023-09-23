{"metadata":{"kernelspec":{"name":"ir","display_name":"R","language":"R"},"language_info":{"name":"R","codemirror_mode":"r","pygments_lexer":"r","mimetype":"text/x-r-source","file_extension":".r","version":"4.0.5"}},"nbformat_minor":4,"nbformat":4,"cells":[{"cell_type":"code","source":"#remotes::install_github(\"satijalab/seurat-data\", \"seurat5\", quiet = TRUE)\n#remotes::install_github(\"mojaveazure/seurat-object\", \"seurat5\", quiet = TRUE)\n#remotes::install_github(\"satijalab/azimuth\", \"seurat5\", quiet = TRUE)\n#remotes::install_github(\"satijalab/seurat-wrappers\", \"seurat5\", quiet = TRUE)\n#remotes::install_github(\"stuart-lab/signac\", \"seurat5\", quiet = TRUE)","metadata":{"_uuid":"ab0f3604-f24b-407f-8cfe-4ca5f0addb04","_cell_guid":"d22cffb2-57f6-46d4-be68-07a8594823a2","collapsed":false,"_execution_state":"idle","jupyter":{"outputs_hidden":false},"execution":{"iopub.status.busy":"2023-09-23T17:47:43.484503Z","iopub.execute_input":"2023-09-23T17:47:43.486891Z","iopub.status.idle":"2023-09-23T17:47:43.578672Z"},"trusted":true},"execution_count":null,"outputs":[]},{"cell_type":"code","source":"library(dplyr)\nlibrary(Seurat)\nlibrary(patchwork)","metadata":{"execution":{"iopub.status.busy":"2023-09-23T17:47:43.582063Z","iopub.execute_input":"2023-09-23T17:47:43.619768Z","iopub.status.idle":"2023-09-23T17:47:51.992134Z"},"trusted":true},"execution_count":null,"outputs":[]},{"cell_type":"code","source":"# Load the PBMC dataset\npbmc.data <- Read10X(data.dir = \"/kaggle/input/scanpydatasets/hg19\")\n# Initialize the Seurat object with the raw (non-normalized data).\npbmc <- CreateSeuratObject(counts = pbmc.data, project = \"pbmc3k\", min.cells = 3, min.features = 200)\npbmc","metadata":{"execution":{"iopub.status.busy":"2023-09-23T17:47:51.995973Z","iopub.execute_input":"2023-09-23T17:47:51.998487Z","iopub.status.idle":"2023-09-23T17:47:57.586186Z"},"trusted":true},"execution_count":null,"outputs":[]},{"cell_type":"code","source":"#QC and selecting cells for further analysis: The [[ operator can add columns to object metadata. This is a great place to stash QC stats\npbmc[[\"percent.mt\"]] <- PercentageFeatureSet(pbmc, pattern = \"^MT-\")","metadata":{"execution":{"iopub.status.busy":"2023-09-23T17:47:57.598279Z","iopub.execute_input":"2023-09-23T17:47:57.602447Z","iopub.status.idle":"2023-09-23T17:47:57.674932Z"},"trusted":true},"execution_count":null,"outputs":[]},{"cell_type":"code","source":"# Visualize QC metrics as a violin plot\nVlnPlot(pbmc, features = c(\"nFeature_RNA\", \"nCount_RNA\", \"percent.mt\"), ncol = 3)","metadata":{"execution":{"iopub.status.busy":"2023-09-23T17:47:57.681199Z","iopub.execute_input":"2023-09-23T17:47:57.685536Z","iopub.status.idle":"2023-09-23T17:48:01.122053Z"},"trusted":true},"execution_count":null,"outputs":[]},{"cell_type":"code","source":"# FeatureScatter is typically used to visualize feature-feature relationships, but can be used\n# for anything calculated by the object, i.e. columns in object metadata, PC scores etc.\n\nplot1 <- FeatureScatter(pbmc, feature1 = \"nCount_RNA\", feature2 = \"percent.mt\")\nplot2 <- FeatureScatter(pbmc, feature1 = \"nCount_RNA\", feature2 = \"nFeature_RNA\")\nplot1 + plot2","metadata":{"execution":{"iopub.status.busy":"2023-09-23T17:48:01.131761Z","iopub.execute_input":"2023-09-23T17:48:01.141526Z","iopub.status.idle":"2023-09-23T17:48:02.986035Z"},"trusted":true},"execution_count":null,"outputs":[]},{"cell_type":"code","source":"pbmc <- subset(pbmc, subset = nFeature_RNA > 200 & nFeature_RNA < 2500 & percent.mt < 5)","metadata":{"execution":{"iopub.status.busy":"2023-09-23T17:48:02.996236Z","iopub.execute_input":"2023-09-23T17:48:02.998316Z","iopub.status.idle":"2023-09-23T17:48:03.973817Z"},"trusted":true},"execution_count":null,"outputs":[]},{"cell_type":"code","source":"#Normalizing the data\npbmc <- NormalizeData(pbmc, normalization.method = \"LogNormalize\", scale.factor = 10000)","metadata":{"execution":{"iopub.status.busy":"2023-09-23T17:48:03.977664Z","iopub.execute_input":"2023-09-23T17:48:03.979780Z","iopub.status.idle":"2023-09-23T17:48:04.313423Z"},"trusted":true},"execution_count":null,"outputs":[]},{"cell_type":"code","source":"pbmc <- NormalizeData(pbmc)","metadata":{"execution":{"iopub.status.busy":"2023-09-23T17:48:04.317231Z","iopub.execute_input":"2023-09-23T17:48:04.319247Z","iopub.status.idle":"2023-09-23T17:48:04.887755Z"},"trusted":true},"execution_count":null,"outputs":[]},{"cell_type":"code","source":"#Identification of highly variable features (feature selection)\npbmc <- FindVariableFeatures(pbmc, selection.method = \"vst\", nfeatures = 2000)\n\n# Identify the 10 most highly variable genes\ntop10 <- head(VariableFeatures(pbmc), 10)\n\n# plot variable features with and without labels\nplot1 <- VariableFeaturePlot(pbmc)\nplot2 <- LabelPoints(plot = plot1, points = top10, repel = TRUE)\nplot1 + plot2","metadata":{"execution":{"iopub.status.busy":"2023-09-23T17:48:04.893410Z","iopub.execute_input":"2023-09-23T17:48:04.897104Z","iopub.status.idle":"2023-09-23T17:48:08.680327Z"},"trusted":true},"execution_count":null,"outputs":[]},{"cell_type":"code","source":"#Scaling the data\nall.genes <- rownames(pbmc)\npbmc <- ScaleData(pbmc, features = all.genes)","metadata":{"execution":{"iopub.status.busy":"2023-09-23T17:48:08.683969Z","iopub.execute_input":"2023-09-23T17:48:08.685704Z","iopub.status.idle":"2023-09-23T17:48:11.189321Z"},"trusted":true},"execution_count":null,"outputs":[]},{"cell_type":"code","source":"#Perform linear dimensional reduction\npbmc <- RunPCA(pbmc, features = VariableFeatures(object = pbmc))\n# Examine and visualize PCA results a few different ways\nprint(pbmc[[\"pca\"]], dims = 1:5, nfeatures = 5)\nVizDimLoadings(pbmc, dims = 1:2, reduction = \"pca\")","metadata":{"execution":{"iopub.status.busy":"2023-09-23T17:48:11.193022Z","iopub.execute_input":"2023-09-23T17:48:11.194544Z","iopub.status.idle":"2023-09-23T17:48:14.774128Z"},"trusted":true},"execution_count":null,"outputs":[]},{"cell_type":"code","source":"DimPlot(pbmc, reduction = \"pca\")","metadata":{"execution":{"iopub.status.busy":"2023-09-23T17:48:14.777645Z","iopub.execute_input":"2023-09-23T17:48:14.779786Z","iopub.status.idle":"2023-09-23T17:48:15.485714Z"},"trusted":true},"execution_count":null,"outputs":[]},{"cell_type":"code","source":"DimHeatmap(pbmc, dims = 1, cells = 500, balanced = TRUE)","metadata":{"execution":{"iopub.status.busy":"2023-09-23T17:48:15.489118Z","iopub.execute_input":"2023-09-23T17:48:15.491078Z","iopub.status.idle":"2023-09-23T17:48:15.664886Z"},"trusted":true},"execution_count":null,"outputs":[]},{"cell_type":"code","source":"DimHeatmap(pbmc, dims = 1:15, cells = 500, balanced = TRUE)","metadata":{"execution":{"iopub.status.busy":"2023-09-23T17:48:15.668463Z","iopub.execute_input":"2023-09-23T17:48:15.670200Z","iopub.status.idle":"2023-09-23T17:48:16.407852Z"},"trusted":true},"execution_count":null,"outputs":[]},{"cell_type":"code","source":"#Determine the ‘dimensionality’ of the dataset\n# NOTE: This process can take a long time for big datasets, comment out for expediency. More\n# approximate techniques such as those implemented in ElbowPlot() can be used to reduce\n# computation time\npbmc <- JackStraw(pbmc, num.replicate = 100)\npbmc <- ScoreJackStraw(pbmc, dims = 1:20)","metadata":{"execution":{"iopub.status.busy":"2023-09-23T17:48:16.411539Z","iopub.execute_input":"2023-09-23T17:48:16.413477Z","iopub.status.idle":"2023-09-23T17:50:13.537511Z"},"trusted":true},"execution_count":null,"outputs":[]},{"cell_type":"code","source":"JackStrawPlot(pbmc, dims = 1:15)\nElbowPlot(pbmc)","metadata":{"execution":{"iopub.status.busy":"2023-09-23T17:50:13.541030Z","iopub.execute_input":"2023-09-23T17:50:13.542416Z","iopub.status.idle":"2023-09-23T17:50:14.696467Z"},"trusted":true},"execution_count":null,"outputs":[]},{"cell_type":"code","source":"#Cluster the cells\npbmc <- FindNeighbors(pbmc, dims = 1:10)\npbmc <- FindClusters(pbmc, resolution = 0.5)","metadata":{"execution":{"iopub.status.busy":"2023-09-23T17:50:14.699983Z","iopub.execute_input":"2023-09-23T17:50:14.701292Z","iopub.status.idle":"2023-09-23T17:50:16.503998Z"},"trusted":true},"execution_count":null,"outputs":[]},{"cell_type":"code","source":"# Look at cluster IDs of the first 5 cells\nhead(Idents(pbmc), 5)","metadata":{"execution":{"iopub.status.busy":"2023-09-23T17:50:16.507354Z","iopub.execute_input":"2023-09-23T17:50:16.508653Z","iopub.status.idle":"2023-09-23T17:50:16.527272Z"},"trusted":true},"execution_count":null,"outputs":[]},{"cell_type":"code","source":"#Run non-linear dimensional reduction (UMAP/tSNE)\n# If you haven't installed UMAP, you can do so via reticulate::py_install(packages =\n# 'umap-learn')\npbmc <- RunUMAP(pbmc, dims = 1:10)","metadata":{"execution":{"iopub.status.busy":"2023-09-23T17:50:16.530572Z","iopub.execute_input":"2023-09-23T17:50:16.531860Z","iopub.status.idle":"2023-09-23T17:50:22.383432Z"},"trusted":true},"execution_count":null,"outputs":[]},{"cell_type":"code","source":"# note that you can set `label = TRUE` or use the LabelClusters function to help label\n# individual clusters\nDimPlot(pbmc, reduction = \"umap\")","metadata":{"execution":{"iopub.status.busy":"2023-09-23T17:50:22.386817Z","iopub.execute_input":"2023-09-23T17:50:22.388135Z","iopub.status.idle":"2023-09-23T17:50:22.888339Z"},"trusted":true},"execution_count":null,"outputs":[]},{"cell_type":"code","source":"#saveRDS(pbmc, file = \"../output/pbmc_tutorial.rds\")","metadata":{"execution":{"iopub.status.busy":"2023-09-23T17:50:22.891967Z","iopub.execute_input":"2023-09-23T17:50:22.894062Z","iopub.status.idle":"2023-09-23T17:50:22.904941Z"},"trusted":true},"execution_count":null,"outputs":[]},{"cell_type":"code","source":"#Finding differentially expressed features (cluster biomarkers)\n# find all markers of cluster 2\ncluster2.markers <- FindMarkers(pbmc, ident.1 = 2, min.pct = 0.25)\nhead(cluster2.markers, n = 5)","metadata":{"execution":{"iopub.status.busy":"2023-09-23T17:50:22.908246Z","iopub.execute_input":"2023-09-23T17:50:22.918003Z","iopub.status.idle":"2023-09-23T17:50:25.469878Z"},"trusted":true},"execution_count":null,"outputs":[]},{"cell_type":"code","source":"# find all markers distinguishing cluster 5 from clusters 0 and 3\ncluster5.markers <- FindMarkers(pbmc, ident.1 = 5, ident.2 = c(0, 3), min.pct = 0.25)\nhead(cluster5.markers, n = 5)","metadata":{"execution":{"iopub.status.busy":"2023-09-23T17:50:25.473250Z","iopub.execute_input":"2023-09-23T17:50:25.474712Z","iopub.status.idle":"2023-09-23T17:50:29.068993Z"},"trusted":true},"execution_count":null,"outputs":[]},{"cell_type":"code","source":"# find markers for every cluster compared to all remaining cells, report only the positive\n# ones\npbmc.markers <- FindAllMarkers(pbmc, only.pos = TRUE, min.pct = 0.25, logfc.threshold = 0.25)\npbmc.markers %>%\n    group_by(cluster) %>%\n    slice_max(n = 2, order_by = avg_log2FC)","metadata":{"execution":{"iopub.status.busy":"2023-09-23T17:50:29.072359Z","iopub.execute_input":"2023-09-23T17:50:29.073655Z","iopub.status.idle":"2023-09-23T17:50:50.875968Z"},"trusted":true},"execution_count":null,"outputs":[]},{"cell_type":"code","source":"cluster0.markers <- FindMarkers(pbmc, ident.1 = 0, logfc.threshold = 0.25, test.use = \"roc\", only.pos = TRUE)","metadata":{"execution":{"iopub.status.busy":"2023-09-23T17:50:50.879234Z","iopub.execute_input":"2023-09-23T17:50:50.880535Z","iopub.status.idle":"2023-09-23T17:50:53.099448Z"},"trusted":true},"execution_count":null,"outputs":[]},{"cell_type":"code","source":"VlnPlot(pbmc, features = c(\"MS4A1\", \"CD79A\"))","metadata":{"execution":{"iopub.status.busy":"2023-09-23T17:50:53.102987Z","iopub.execute_input":"2023-09-23T17:50:53.104360Z","iopub.status.idle":"2023-09-23T17:50:53.998184Z"},"trusted":true},"execution_count":null,"outputs":[]},{"cell_type":"code","source":"# you can plot raw counts as well\nVlnPlot(pbmc, features = c(\"NKG7\", \"PF4\"), slot = \"counts\", log = TRUE)","metadata":{"execution":{"iopub.status.busy":"2023-09-23T17:50:54.001830Z","iopub.execute_input":"2023-09-23T17:50:54.003903Z","iopub.status.idle":"2023-09-23T17:50:54.976495Z"},"trusted":true},"execution_count":null,"outputs":[]},{"cell_type":"code","source":"FeaturePlot(pbmc, features = c(\"MS4A1\", \"GNLY\", \"CD3E\", \"CD14\", \"FCER1A\", \"FCGR3A\", \"LYZ\", \"PPBP\",\n    \"CD8A\"))","metadata":{"execution":{"iopub.status.busy":"2023-09-23T17:50:54.980108Z","iopub.execute_input":"2023-09-23T17:50:54.982216Z","iopub.status.idle":"2023-09-23T17:50:57.863583Z"},"trusted":true},"execution_count":null,"outputs":[]},{"cell_type":"code","source":"pbmc.markers %>%\n    group_by(cluster) %>%\n    top_n(n = 10, wt = avg_log2FC) -> top10\nDoHeatmap(pbmc, features = top10$gene) + NoLegend()","metadata":{"execution":{"iopub.status.busy":"2023-09-23T17:50:57.867137Z","iopub.execute_input":"2023-09-23T17:50:57.869143Z","iopub.status.idle":"2023-09-23T17:51:01.104418Z"},"trusted":true},"execution_count":null,"outputs":[]},{"cell_type":"code","source":"#Assigning cell type identity to clusters\nnew.cluster.ids <- c(\"Naive CD4 T\", \"CD14+ Mono\", \"Memory CD4 T\", \"B\", \"CD8 T\", \"FCGR3A+ Mono\",\n    \"NK\", \"DC\", \"Platelet\")\nnames(new.cluster.ids) <- levels(pbmc)\npbmc <- RenameIdents(pbmc, new.cluster.ids)\nDimPlot(pbmc, reduction = \"umap\", label = TRUE, pt.size = 0.5) + NoLegend()","metadata":{"execution":{"iopub.status.busy":"2023-09-23T17:51:01.107863Z","iopub.execute_input":"2023-09-23T17:51:01.110003Z","iopub.status.idle":"2023-09-23T17:51:01.618339Z"},"trusted":true},"execution_count":null,"outputs":[]}]}