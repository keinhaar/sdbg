/*
 * Copyright (c) 2022, SDBG Project.
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
package com.github.sdbg.debug.core.model;

import com.github.sdbg.debug.core.SDBGDebugCorePlugin;

import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Status;
import org.eclipse.debug.core.DebugException;
import org.eclipse.debug.core.model.DebugElement;
import org.eclipse.debug.core.model.IDebugTarget;

/**
 * The abstract super class of the Browser debug elements. This provides common
 * functionality like access to the debug target and ILaunch object, as well as
 * making sure that all browser debug elements return the return
 * SDBGDebugCorePlugin.DEBUG_MODEL_ID debug model identifier.
 */
public abstract class BrowserDebugElement<T extends ISDBGDebugTarget> extends DebugElement
{

    /**
     * Create a new Browser debug element.
     * 
     * @param target
     */
    public BrowserDebugElement(IDebugTarget target)
    {
        super(target);
    }

    /**
     * Create a new DebugException wrapping the given Throwable.
     * 
     * @param exception
     * @return
     */
    protected DebugException createDebugException(Throwable exception)
    {
        if (exception instanceof DebugException)
        {
            return (DebugException) exception;
        }
        else
        {
            return new DebugException(
                new Status(IStatus.ERROR, SDBGDebugCorePlugin.PLUGIN_ID, exception.getMessage(), exception));
        }
    }

    @Override
    public String getModelIdentifier()
    {
        return SDBGDebugCorePlugin.DEBUG_MODEL_ID;
    }

    /**
     */
    @SuppressWarnings("unchecked")
    public T getTarget()
    {
        return (T) getDebugTarget();
    }
}
