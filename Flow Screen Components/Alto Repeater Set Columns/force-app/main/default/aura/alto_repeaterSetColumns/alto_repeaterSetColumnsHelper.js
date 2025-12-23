({
    markRepeater: function(component) {
        console.log('[AltoRepeaterSetColumns] Marking parent repeater');
        
        try {
            const componentElement = component.find('componentContainer').getElement();
            const parentRepeater = componentElement.closest('flowruntime-repeater');
            
            if (!parentRepeater) {
                console.warn('[AltoRepeaterSetColumns] Parent flowruntime-repeater not found');
                return;
            }
            
            const uniqueId = component.get('v.uniqueId');
            const classPrefix = 'alto-cols-';
            
            // Check if parent already has a class with our prefix
            const existingClass = Array.from(parentRepeater.classList).find(cls => cls.startsWith(classPrefix));
            
            if (existingClass) {
                console.log('[AltoRepeaterSetColumns] Parent repeater already has class:', existingClass, '- skipping to allow inheritance');
                return;
            }
            
            // Apply the unique ID class
            parentRepeater.classList.add(uniqueId);
            
            console.log('[AltoRepeaterSetColumns] Parent repeater marked with class:', uniqueId);
        } catch (error) {
            console.error('[AltoRepeaterSetColumns] Error marking repeater:', error);
        }
    },
    
    injectStyles: function(component) {
        console.log('[AltoRepeaterSetColumns] Injecting styles');
        
        try {
            const columnsXL = component.get('v.columnsXL');
            const columns = component.get('v.columns');
            const columnsMedium = component.get('v.columnsMedium');
            const columnsSmall = component.get('v.columnsSmall');
            const uniqueId = component.get('v.uniqueId');
            
            if (!columnsXL || columnsXL <= 0) {
                console.warn('[AltoRepeaterSetColumns] Invalid columnsXL value:', columnsXL);
                return;
            }
            
            if (!uniqueId) {
                console.warn('[AltoRepeaterSetColumns] No unique ID set');
                return;
            }
            
            // Calculate width percentages for each breakpoint (4 decimal places for precision)
            const widthPercentXL = (100 / columnsXL).toFixed(4);
            const widthPercentLarge = (100 / (columns || columnsXL)).toFixed(4);
            const widthPercentMedium = (100 / (columnsMedium || columns || columnsXL)).toFixed(4);
            const widthPercentSmall = (100 / (columnsSmall || 1)).toFixed(4);
            
            console.log('[AltoRepeaterSetColumns] Calculated widths - XL:', widthPercentXL + '% (' + columnsXL + ' cols), Large:', widthPercentLarge + '% (' + (columns || columnsXL) + ' cols), Medium:', widthPercentMedium + '% (' + (columnsMedium || columns || columnsXL) + ' cols), Small:', widthPercentSmall + '% (' + (columnsSmall || 1) + ' cols)');
            
            // Create style element with responsive CSS for all breakpoints
            const css = `
                /* Extra-large screens (1440px+) - ${columnsXL} columns */
                flowruntime-repeater.${uniqueId} flowruntime-repeater-instance fieldset > .slds-grid flowruntime-screen-field {
                    width: ${widthPercentXL}% !important;
                    flex: none !important;
                    min-width: auto !important;
                }
                
                /* Large screens (1024px-1439px) - ${columns || columnsXL} columns */
                @media (max-width: 1439px) {
                    flowruntime-repeater.${uniqueId} flowruntime-repeater-instance fieldset > .slds-grid flowruntime-screen-field {
                        width: ${widthPercentLarge}% !important;
                    }
                }
                
                /* Medium screens (768px-1023px) - ${columnsMedium || columns || columnsXL} columns */
                @media (max-width: 1023px) {
                    flowruntime-repeater.${uniqueId} flowruntime-repeater-instance fieldset > .slds-grid flowruntime-screen-field {
                        width: ${widthPercentMedium}% !important;
                    }
                }
                
                /* Small screens (below 768px) - ${columnsSmall || 1} columns */
                @media (max-width: 767px) {
                    flowruntime-repeater.${uniqueId} flowruntime-repeater-instance fieldset > .slds-grid flowruntime-screen-field {
                        width: ${widthPercentSmall}% !important;
                    }
                }
            `;
            
            // Get or create style container
            const styleContainer = component.find('styleContainer').getElement();
            
            // Clear existing styles and inject new ones
            styleContainer.innerHTML = '<style>' + css + '</style>';
            
            console.log('[AltoRepeaterSetColumns] Styles injected successfully');
            
        } catch (error) {
            console.error('[AltoRepeaterSetColumns] Error injecting styles:', error);
        }
    }
})