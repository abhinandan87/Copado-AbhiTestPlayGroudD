//--------------------
// @Author: Vishnu Vardhan Chowdary
// @Date: 06 nov 2018
// @Company: Vertiba
// @Description: Apex doesn't expose dependent picklist info directly. This class helps in getting the 
// 		dependent picklist values Code has been taken from 
// 		https://gist.github.com/anonymous/32e14c2002c5f79896ba33cef7236f1a
//-----------------------
public class DependentPicklistUtil {
    //-----------------------------
    // @author: Vishnu Vardhan Chowdary
    // @date: 06 Nov 2018
    // @param: theField - dependent picklist field for which you want values
    // @param: ctrlField - Controlling picklist field
    // @description: SFDC1-10251 : Convert a base64 token into a binary/bits representation
    //    e.g. 'gAAA' => '100000000000000000000'
    // @return Map<String, List<String>>
    //------------------------------
    public static Map<String, Set<String>> getDependentOptionsImpl(Schema.SObjectField theField, Schema.SObjectField ctrlField) {
        // validFor property cannot be accessed via a method or a property,
        // so we need to serialize the PicklistEntry object and then deserialize into a wrapper.
        system.debug(ctrlField.getDescribe().getType());
        List<Schema.PicklistEntry> contrEntries = new List<Schema.PicklistEntry>();
        // Set up the return container - Map<ControllingValue, List<DependentValues>>
        Map<String, Set<String>> objResults = new Map<String, Set<String>>();
        List<String> controllingValues = new List<String>();
        //Here we check the type, because dependent picklists can be based off of checkboxes, or other picklists.
        //If the controlling field is a checkbox, add 'Unchecked and 'Checked' values to objResults, and controllingValues.
        //If it is a picklist, continue the code as it did normally.
        if(String.valueOf(ctrlField.getDescribe().getType()) == 'BOOLEAN') {
            objResults.put('Unchecked', new Set<String>());
            objResults.put('Checked', new Set<String>());
            controllingValues.add('Unchecked');
            controllingValues.add('Checked');
        }
        else if(String.valueOf(ctrlField.getDescribe().getType()) == 'PICKLIST') {
            contrEntries = ctrlField.getDescribe().getPicklistValues();
            
            for (Schema.PicklistEntry ple : contrEntries) {
                String label = ple.getLabel();
                objResults.put(label, new Set<String>());
                controllingValues.add(label);
            }
        }
        List<PicklistEntryWrapper> depEntries =
            DependentPicklistUtil.wrapPicklistEntries(theField.getDescribe().getPicklistValues());
        
        for (PicklistEntryWrapper plew : depEntries) {
            String label = plew.label;
            String validForBits = base64ToBits(plew.validFor);
            for (Integer i = 0; i < validForBits.length(); i++) {
                // For each bit, in order: if it's a 1, add this label to the dependent
                // list for the corresponding controlling value
                String bit = validForBits.mid(i, 1);
                if (bit == '1') {
                    objResults.get(controllingValues.get(i)).add(label);
                }
            }
        }
        return objResults;
    }
    
    //-----------------------------
    // @author: Vishnu Vardhan Chowdary
    // @date: 06 Nov 2018
    // @param: Integer
    // @description: SFDC1-10251 : Convert decimal to binary representation (alas, Apex has no native method :-(
    //    eg. 4 => '100', 19 => '10011', etc. Approach: Divide by 2 repeatedly until 0. At each step note the 
    //    remainder (0 or 1). These, in reverse order, are the binary.
    // @return String
    //------------------------------
    public static String decimalToBinary(Integer val) {
        String bits = '';
        while (val > 0) {
            Integer remainder = Math.mod(val, 2);
            val = Integer.valueOf(Math.floor(val / 2));
            bits = String.valueOf(remainder) + bits;
        }
        return bits;
    }
    
    //-----------------------------
    // @author: Vishnu Vardhan Chowdary
    // @date: 06 Nov 2018
    // @param: String
    // @description: SFDC1-10251 : Convert a base64 token into a binary/bits representation
    //    e.g. 'gAAA' => '100000000000000000000'
    // @return String
    //------------------------------
    public static String base64ToBits(String validFor) {
        if (String.isEmpty(validFor)) return '';
        
        String validForBits = '';
        for (Integer i = 0; i < validFor.length(); i++) {
            String thisChar = validFor.mid(i, 1);
            Integer val = base64Chars.indexOf(thisChar);
            String bits = decimalToBinary(val).leftPad(6, '0');
            validForBits += bits;
        }
        return validForBits;
    }
    
    private static final String base64Chars = '' +
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
        'abcdefghijklmnopqrstuvwxyz' +
        '0123456789+/';
    
    //-----------------------------
    // @author: Vishnu Vardhan Chowdary
    // @date: 06 Nov 2018
    // @param: List<Schema.PickListEntry>
    // @description: SFDC1-10251 : Serializes and deserializes picklist entries. ValidFor will be visible only
    // 		when the picklist entry is deserialized, but cant be fetched directly.
    // @return List<PickListEntryWrapper>
    //------------------------------
    private static List<PicklistEntryWrapper> wrapPicklistEntries(List<Schema.PicklistEntry> PLEs) {
        return (List<PicklistEntryWrapper>)
            JSON.deserialize(JSON.serialize(PLEs), List<PicklistEntryWrapper>.class);
    }

    //-----------------------------
    // @author: Vishnu Vardhan Chowdary
    // @date: 06 Nov 2018
    // @description: SFDC1-10251 : Wrapper class to hold the picklist value.
    //------------------------------
    public class PicklistEntryWrapper {
        public String active {get; set;}
        public String defaultValue {get; set;}
        public String label {get; set;}
        public String value {get; set;}
        public String validFor {get; set;}
    }
}