public with sharing class SeguimientoClima {
    
    private static final String NAMED_CREDENTIAL = 'callout:OpenWeather';
    
    @future(callout=true)
    public static void obtenerClimaParaSeguimientos(Set<Id> seguimientoIds) {
        try {
            List<Seguimiento__c> seguimientos = [SELECT Id, Ubicacion__c 
                                               FROM Seguimiento__c 
                                               WHERE Id IN :seguimientoIds 
                                               AND Ubicacion__c != null];
            
            List<Seguimiento__c> seguimientosToUpdate = new List<Seguimiento__c>();
            
            for (Seguimiento__c seguimiento : seguimientos) {
                String weatherData = obtenerDatosClimaSync(seguimiento.Ubicacion__c);
                if (String.isNotBlank(weatherData) && !weatherData.startsWith('Error') && !weatherData.startsWith('Sin')) {
                    seguimiento.Clima_Actual__c = weatherData;
                    seguimientosToUpdate.add(seguimiento);
                }
            }
            
            if (!seguimientosToUpdate.isEmpty()) {
                update seguimientosToUpdate;
                System.debug('Updated ' + seguimientosToUpdate.size() + ' seguimiento records with weather data');
            }
            
        } catch (Exception e) {
            System.debug('Exception occurred while updating seguimientos with weather data: ' + e.getMessage());
        }
    }
    
    private static String obtenerDatosClimaSync(String cityName) {
        try {
            // Get API key from Custom Metadata Type
            String apiKey = getApiKey();
            if (String.isBlank(apiKey)) {
                System.debug('API Key not found in Custom Metadata Type');
                return 'Error: API Key no configurada';
            }
            
            // Build the API URL using Named Credential
            String apiUrl = NAMED_CREDENTIAL + '/data/2.5/weather?q=' + EncodingUtil.urlEncode(cityName, 'UTF-8') + '&units=metric&appid=' + apiKey;
            
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(apiUrl);
            request.setMethod('GET');
            request.setTimeout(10000);
            
            HttpResponse response = http.send(request);
            
            if (response.getStatusCode() == 200) {
                return procesarDatosClimaParaCampo(response.getBody(), cityName);
            } else {
                System.debug('Error calling Weather API for ' + cityName + '. Status Code: ' + response.getStatusCode());
                return 'Error API';
            }
            
        } catch (Exception e) {
            System.debug('Exception occurred while calling Weather API for ' + cityName + ': ' + e.getMessage());
            return 'Sin conexión';
        }
    }
    
    private static String getApiKey() {
        try {
            // Query Custom Metadata Type for OpenWeather API Key
            ApiKey__mdt apiKeyRecord = [SELECT key__c 
                                        FROM ApiKey__mdt 
                                        WHERE Label = 'OpenWeather' 
                                        LIMIT 1];
            return apiKeyRecord.key__c;
        } catch (Exception e) {
            System.debug('Error retrieving API Key from Custom Metadata: ' + e.getMessage());
            return null;
        }
    }
    
    private static String procesarDatosClimaParaCampo(String jsonResponse, String cityName) {
        try {
            Map<String, Object> weatherData = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
            
            Map<String, Object> main = (Map<String, Object>) weatherData.get('main');
            List<Object> weatherArray = (List<Object>) weatherData.get('weather');
            Map<String, Object> weather = (Map<String, Object>) weatherArray[0];
            
            Double temperature = (Double) main.get('temp');
            Double humidity = (Double) main.get('humidity');
            String description = (String) weather.get('description');
            String mainWeather = (String) weather.get('main');
            
            // Formato más corto para que quepa en el campo
            String climaActual = mainWeather + ', ' + temperature.intValue() + '°C, ' + humidity.intValue() + '%';
            
            System.debug('Weather data for ' + cityName + ': ' + climaActual);
            return climaActual;
            
        } catch (Exception e) {
            System.debug('Error processing weather data for ' + cityName + ': ' + e.getMessage());
            return 'Error procesando';
        }
    }
}