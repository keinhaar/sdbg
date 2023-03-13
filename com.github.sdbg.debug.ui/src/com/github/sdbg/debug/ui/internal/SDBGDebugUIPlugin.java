/*
 * Copyright (c) 2012, the Dart project authors.
 * 
 * Licensed under the Eclipse Public License v1.0 (the "License"); you may not use this file except
 * in compliance with the License. You may obtain a copy of the License at
 * 
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Unless required by applicable law or agreed to in writing, software distributed under the License
 * is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
 * or implied. See the License for the specific language governing permissions and limitations under
 * the License.
 */
package com.github.sdbg.debug.ui.internal;

import com.github.sdbg.debug.core.SDBGDebugCorePlugin;
import com.github.sdbg.debug.ui.internal.objectinspector.InspectorActionFilter;
import com.github.sdbg.debug.ui.internal.presentation.SDBGElementAdapterFactory;
import com.github.sdbg.debug.ui.internal.util.PreferencesAdapter;

import java.util.HashMap;
import java.util.Map;

import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Status;
import org.eclipse.jface.preference.IPreferenceStore;
import org.eclipse.jface.resource.ImageDescriptor;
import org.eclipse.swt.graphics.Image;
import org.eclipse.ui.editors.text.EditorsUI;
import org.eclipse.ui.plugin.AbstractUIPlugin;
import org.eclipse.ui.texteditor.ChainedPreferenceStore;
import org.osgi.framework.BundleContext;

/**
 * The activator class controls the plug-in life cycle
 */
public class SDBGDebugUIPlugin extends AbstractUIPlugin {

  public static final String PLUGIN_ID = "com.github.sdbg.debug.ui"; //$NON-NLS-1$

  private static Map<ImageDescriptor, Image> imageCache = new HashMap<ImageDescriptor, Image>();

  private Map<String, Image> imageMap;

  /**
   * The combined preference store.
   */
  private IPreferenceStore combinedPreferenceStore;

  /**
   * The shared instance
   */
  private static SDBGDebugUIPlugin plugin;

  /**
   * Returns the shared instance
   * 
   * @return the shared instance
   */
  public static SDBGDebugUIPlugin getDefault() {
    return plugin;
  }

  public static Image getImage(ImageDescriptor imageDescriptor) {
    Image image = imageCache.get(imageDescriptor);

    if (image == null) {
      image = imageDescriptor.createImage();

      imageCache.put(imageDescriptor, image);
    }

    return image;
  }

  /**
   * Get a image from this plugin's icons directory.
   * 
   * @param imagePath the image path, relative to the icons directory.
   * @return the specified image
   */
  public static Image getImage(String imagePath) {
    return getDefault().getPluginImage(imagePath);
  }

  public static ImageDescriptor getImageDescriptor(String path) {
    return imageDescriptorFromPlugin(PLUGIN_ID, "icons/" + path);
  }

  /**
   * Log an error message
   * 
   * @param message the error messsage
   */
  public static void logError(String message) {
    getDefault().getLog().log(new Status(IStatus.ERROR, SDBGDebugUIPlugin.PLUGIN_ID, message));
  }

  /**
   * Log the specified error to the Eclipse error log
   * 
   * @param e the exception
   */
  public static void logError(Throwable e) {
    getDefault().getLog().log(
        new Status(IStatus.ERROR, SDBGDebugUIPlugin.PLUGIN_ID, e.toString(), e));
  }

  /**
   * Returns a combined preference store, this store is read-only.
   * 
   * @return the combined preference store
   */
  @SuppressWarnings("deprecation")
  public IPreferenceStore getCombinedPreferenceStore() {
    if (combinedPreferenceStore == null) {
      IPreferenceStore generalTextStore = EditorsUI.getPreferenceStore();
      combinedPreferenceStore = new ChainedPreferenceStore(new IPreferenceStore[] {
          getPreferenceStore(),
          new PreferencesAdapter(SDBGDebugCorePlugin.getPlugin().getPluginPreferences()),
          generalTextStore});
    }
    return combinedPreferenceStore;
  }

  /**
   * Called when the bundle is first started
   */
  @Override
  public void start(BundleContext context) throws Exception {
    plugin = this;

    imageMap = new HashMap<String, Image>();

    super.start(context);

    SDBGElementAdapterFactory.init();

    InspectorActionFilter.registerAdapters();

    // Install our user agent manager.
    SDBGDebugUserAgentManager.install();
  }

  /**
   * Called when the bundle is stopped
   */
  @Override
  public void stop(BundleContext context) throws Exception {

    super.stop(context);

    disposeImageCache();

    plugin = null;
  }

  private void disposeImageCache() {
    for (Image image : imageMap.values()) {
      image.dispose();
    }

    imageMap = null;
  }

  private Image getPluginImage(String imagePath) {
    if (imageMap.get(imagePath) == null) {
      ImageDescriptor imageDescriptor = imageDescriptorFromPlugin(PLUGIN_ID, "icons/" + imagePath);

      if (imageDescriptor != null) {
        imageMap.put(imagePath, imageDescriptor.createImage());
      }
    }

    return imageMap.get(imagePath);
  }
}
