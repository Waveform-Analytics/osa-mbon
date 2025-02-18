import pandas as pd
from sklearn.preprocessing import StandardScaler
from sklearn.cluster import KMeans
from sklearn.decomposition import PCA
import matplotlib.pyplot as plt
import seaborn as sns

# Load dataset
file_path = "data/index_data_for_kmeans.csv"  # Change this if running locally
df = pd.read_csv(file_path)

# Select numeric columns (excluding 'Dataset')
numerical_features = df.drop(columns=['Dataset'])

# Standardize features (K-means is sensitive to scale)
scaler = StandardScaler()
scaled_features = scaler.fit_transform(numerical_features)

# Run K-Means with 8 clusters
kmeans = KMeans(n_clusters=8, random_state=42, n_init=10)
df['Cluster'] = kmeans.fit_predict(scaled_features)

# Reduce data to 2 dimensions using PCA
pca = PCA(n_components=2)
reduced_features = pca.fit_transform(scaled_features)

# Convert to DataFrame
df_pca = pd.DataFrame(reduced_features, columns=['PC1', 'PC2'])
df_pca['Cluster'] = df['Cluster']
df_pca['Dataset'] = df['Dataset']

# Save pca results
df_pca.to_csv("data/index_data_for_kmeans_pca.csv", index=False)

# Scatter plot of clusters
plt.figure(figsize=(8, 6))
sns.scatterplot(x='PC1', y='PC2', hue=df_pca['Cluster'], palette='tab10', data=df_pca, s=10, alpha=0.5)
plt.title("PCA showing k-means clusters")
plt.legend(loc='upper right', ncol=2, markerscale=2)
plt.show()

# Scatter plot of PCA components colored by Dataset

plt.figure(figsize=(8, 6), dpi=200)  # Increase resolution and figure size
# Reduce marker size and add transparency
sns.scatterplot(x=df_pca['PC1'], y=df_pca['PC2'], hue=df['Dataset'],
                palette='tab10', data=df_pca, s=10, alpha=0.5)
plt.title("PCA showing location clusters")
# Adjust legend placement and set it to have 2 columns, increase legend dot size
plt.legend(loc='upper right', ncol=2, markerscale=2)
plt.show()
