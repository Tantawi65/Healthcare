#!/usr/bin/env python3
"""
Fix NumPy compatibility issue by regenerating the labels file
"""
import numpy as np
import pickle
import os

def fix_numpy_compatibility():
    try:
        # Try to load the current labels file
        labels_path = "symptom_model.labels.npy"
        
        if not os.path.exists(labels_path):
            print(f"Error: {labels_path} not found")
            return False
            
        print("Attempting to load labels file...")
        
        # Try different methods to load the file
        try:
            # Method 1: Direct numpy load
            classes = np.load(labels_path, allow_pickle=True)
            print("Successfully loaded with direct numpy load")
        except Exception as e1:
            print(f"Direct load failed: {e1}")
            try:
                # Method 2: Load with different encoding
                with open(labels_path, 'rb') as f:
                    classes = pickle.load(f)
                print("Successfully loaded with pickle")
            except Exception as e2:
                print(f"Pickle load failed: {e2}")
                return False
        
        # If we got here, we have the classes
        print(f"Loaded {len(classes)} classes: {classes[:5]}...")
        
        # Save with current NumPy version
        backup_path = "symptom_model.labels.npy.backup"
        if not os.path.exists(backup_path):
            os.rename(labels_path, backup_path)
            print(f"Backed up original file to {backup_path}")
        
        # Save with current NumPy version
        np.save(labels_path, classes, allow_pickle=True)
        print(f"Successfully regenerated {labels_path} with current NumPy version")
        
        # Test loading the new file
        test_classes = np.load(labels_path, allow_pickle=True)
        print(f"Verification successful: loaded {len(test_classes)} classes")
        
        return True
        
    except Exception as e:
        print(f"Error fixing compatibility: {e}")
        return False

if __name__ == "__main__":
    success = fix_numpy_compatibility()
    if success:
        print("✅ NumPy compatibility fixed successfully!")
    else:
        print("❌ Failed to fix NumPy compatibility")