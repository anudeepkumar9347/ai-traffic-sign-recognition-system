import React, { useState, useCallback } from 'react';
import { useDropzone } from 'react-dropzone';
import axios from 'axios';

function App() {
  const [file, setFile] = useState(null);
  const [preview, setPreview] = useState(null);
  const [results, setResults] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  const onDrop = useCallback((acceptedFiles) => {
    const selectedFile = acceptedFiles[0];
    if (selectedFile) {
      setFile(selectedFile);
      setError(null);
      setResults(null);
      
      // Create preview URL
      const previewUrl = URL.createObjectURL(selectedFile);
      setPreview({
        url: previewUrl,
        type: selectedFile.type
      });
    }
  }, []);

  const { getRootProps, getInputProps, isDragActive } = useDropzone({
    onDrop,
    accept: {
      'image/*': ['.jpeg', '.jpg', '.png', '.gif', '.bmp'],
      'video/*': ['.mp4', '.avi', '.mov', '.wmv', '.flv', '.webm']
    },
    multiple: false
  });

  const analyzeFile = async () => {
    if (!file) return;

    setLoading(true);
    setError(null);
    setResults(null);

    const formData = new FormData();
    formData.append('file', file);

    try {
      const response = await axios.post('/api/analyze', formData, {
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      });

      setResults(response.data);
    } catch (err) {
      setError(err.response?.data?.error || 'An error occurred while analyzing the file');
    } finally {
      setLoading(false);
    }
  };

  const renderPreview = () => {
    if (!preview) return null;

    const isVideo = preview.type.startsWith('video/');
    
    return (
      <div className="preview-media">
        {isVideo ? (
          <video controls>
            <source src={preview.url} type={preview.type} />
            Your browser does not support the video tag.
          </video>
        ) : (
          <img src={preview.url} alt="Preview" />
        )}
      </div>
    );
  };

  const renderResults = () => {
    if (loading) {
      return (
        <div className="loading">
          <div className="loading-spinner"></div>
          <p>Analyzing for traffic signs...</p>
        </div>
      );
    }

    if (error) {
      return (
        <div className="error">
          <strong>Error:</strong> {error}
        </div>
      );
    }

    if (results) {
      return (
        <div className="results">
          <h3>Detection Results</h3>
          {results.detections && results.detections.length > 0 ? (
            <>
              <p><strong>Found {results.detections.length} traffic sign(s):</strong></p>
              {results.detections.map((detection, index) => (
                <div key={index} className="sign-detection">
                  <h4>{detection.sign_type}</h4>
                  <p>{detection.description}</p>
                  <span className="confidence">
                    Confidence: {(detection.confidence * 100).toFixed(1)}%
                  </span>
                  {detection.coordinates && (
                    <p>
                      <small>
                        Position: ({detection.coordinates.x}, {detection.coordinates.y}) 
                        Size: {detection.coordinates.width}x{detection.coordinates.height}
                      </small>
                    </p>
                  )}
                </div>
              ))}
            </>
          ) : (
            <p>No traffic signs detected in this image/video.</p>
          )}
          
          {results.processing_time && (
            <p><small>Processing time: {results.processing_time.toFixed(2)}s</small></p>
          )}
        </div>
      );
    }

    return null;
  };

  return (
    <div className="container">
      <div className="header">
        <h1>🚦 AI Traffic Sign Recognition</h1>
        <p>Upload an image or video from your dash cam to detect and recognize traffic signs</p>
      </div>

      <div className="upload-section">
        <div 
          {...getRootProps()} 
          className={`dropzone ${isDragActive ? 'active' : ''}`}
        >
          <input {...getInputProps()} />
          {isDragActive ? (
            <p>Drop the file here...</p>
          ) : (
            <div>
              <p>📁 Drag & drop an image or video here, or click to select</p>
              <p><small>Supported formats: JPEG, PNG, GIF, BMP, MP4, AVI, MOV, WMV, FLV, WebM</small></p>
            </div>
          )}
        </div>

        {file && (
          <div className="file-info">
            <p><strong>Selected file:</strong> {file.name}</p>
            <p><strong>Size:</strong> {(file.size / 1024 / 1024).toFixed(2)} MB</p>
            <p><strong>Type:</strong> {file.type}</p>
          </div>
        )}

        {file && (
          <button 
            className="analyze-button" 
            onClick={analyzeFile}
            disabled={loading}
          >
            {loading ? 'Analyzing...' : '🔍 Analyze for Traffic Signs'}
          </button>
        )}
      </div>

      {preview && (
        <div className="preview-section">
          <div className="preview-container">
            {renderPreview()}
            <div className="results-section">
              {renderResults()}
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

export default App;
