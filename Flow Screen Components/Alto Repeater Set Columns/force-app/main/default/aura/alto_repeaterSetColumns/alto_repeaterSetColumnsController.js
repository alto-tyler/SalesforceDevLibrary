({
    onInit: function(component, event, helper) {
        console.log('[AltoRepeaterSetColumns] Component initialized');
        
        // Generate unique ID from global ID
        const globalId = component.getGlobalId();
        const uniqueId = 'alto-cols-' + globalId.replace(/[^a-zA-Z0-9]/g, '');
        component.set('v.uniqueId', uniqueId);
        
        console.log('[AltoRepeaterSetColumns] Unique ID:', uniqueId);
        
        // Use setTimeout to ensure DOM is fully rendered
        window.setTimeout(
            $A.getCallback(function() {
                helper.markRepeater(component);
                helper.injectStyles(component);
            }), 150
        );
    },
    
    handleColumnsChange: function(component, event, helper) {
        console.log('[AltoRepeaterSetColumns] Columns changed - XL:', component.get('v.columnsXL'), 'Large:', component.get('v.columns'), 'Medium:', component.get('v.columnsMedium'), 'Small:', component.get('v.columnsSmall'));
        helper.injectStyles(component);
    }
})