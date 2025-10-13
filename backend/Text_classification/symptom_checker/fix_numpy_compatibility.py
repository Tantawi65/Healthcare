#!/usr/bin/env python3
"""
Fix NumPy compatibility issue by regenerating the labels file
"""
import numpy as np
import pickle
import sys

def fix_numpy_labels():
    """Regenerate labels file with current NumPy version"""
    labels_file = "symptom_model.labels.npy"
    backup_file = "symptom_model.labels.npy.backup"
    
    try:
        print("Attempting to load existing labels file...")
        
        # Try different methods to load the old file
        try:
            # Method 1: Try loading with allow_pickle=True
            old_labels = np.load(labels_file, allow_pickle=True)
            print(f"Successfully loaded labels: {len(old_labels)} classes")
        except Exception as e1:
            print(f"Method 1 failed: {e1}")
            
            try:
                # Method 2: Try loading with encoding='latin1'
                old_labels = np.load(labels_file, allow_pickle=True, encoding='latin1')
                print(f"Successfully loaded labels with latin1 encoding: {len(old_labels)} classes")
            except Exception as e2:
                print(f"Method 2 failed: {e2}")
                
                # Method 3: Manual pickle loading
                with open(labels_file, 'rb') as f:
                    # Skip numpy header and read pickle data directly
                    magic = f.read(6)
                    if magic[:6] != b'\x93NUMPY':
                        f.seek(0)
                    else:
                        # Skip numpy header
                        version = f.read(2)
                        header_len = int.from_bytes(f.read(2), 'little')
                        header = f.read(header_len)
                    
                    old_labels = pickle.load(f)
                    print(f"Successfully loaded labels with manual method: {len(old_labels)} classes")
        
        # Backup original file
        import shutil
        shutil.copy2(labels_file, backup_file)
        print(f"Backed up original file to {backup_file}")
        
        # Save with current NumPy version
        np.save(labels_file, old_labels)
        print(f"Successfully regenerated {labels_file} with current NumPy version")
        
        # Verify the new file works
        test_labels = np.load(labels_file, allow_pickle=True)
        print(f"Verification successful: {len(test_labels)} classes loaded")
        print(f"Sample classes: {list(test_labels[:5])}")
        
        return True
        
    except Exception as e:
        print(f"Failed to fix labels file: {e}")
        return False

if __name__ == "__main__":
    success = fix_numpy_labels()
    if success:
        print("\n✅ Labels file fixed successfully!")
        print("You can now start the symptom checker server.")
    else:
        print("\n❌ Failed to fix labels file.")
        print("You may need to retrain the model or get a compatible labels file.")
        sys.exit(1)