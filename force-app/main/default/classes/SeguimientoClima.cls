public with sharing class SeguimientoClima {
    
    private static final String API_BASE_URL = 'https://api.openweathermap.org/data/2.5/weather';
    private static final String API_KEY = '70420016226aabcf7677e4703d9714ed';
    
    
    @future(callout=true)
    public static void obtenerClimaParaSeguimientos(Set<Id> seguimientoIds) {
        try {
            // Query the Seguimiento records to get location information
            List<Seguimiento__c> seguimientos = [SELECT Id, Ubicacion__c 
                                               FROM Seguimiento__c 
                                               WHERE Id IN :seguimientoIds 
                                               AND Ubicacion__c != null];
            
            List<Seguimiento__c> seguimientosToUpdate = new List<Seguimiento__c>();
            
            for (Seguimiento__c seguimiento : seguimientos) {
                String weatherData = obtenerDatosClimaSync(seguimiento.Ubicacion__c);
                if (String.isNotBlank(weatherData)) {
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
            // Build the API URL
            String apiUrl = API_BASE_URL + '?q=' + EncodingUtil.urlEncode(cityName, 'UTF-8') + '&appid=' + API_KEY + '&units=metric';
            
            // Make the HTTP callout
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(apiUrl);
            request.setMethod('GET');
            request.setTimeout(10000); // 10 seconds timeout
            
            HttpResponse response = http.send(request);
            
            if (response.getStatusCode() == 200) {
                return procesarDatosClimaParaCampo(response.getBody(), cityName);
            } else {
                System.debug('Error calling Weather API for ' + cityName + '. Status Code: ' + response.getStatusCode());
                return 'Error obteniendo clima';
            }
            
        } catch (Exception e) {
            System.debug('Exception occurred while calling Weather API for ' + cityName + ': ' + e.getMessage());
            return 'Error: ' + e.getMessage();
        }
    }
    
    private static String procesarDatosClimaParaCampo(String jsonResponse, String cityName) {
        try {
            // Parse JSON response
            Map<String, Object> weatherData = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
            
            // Extract weather information
            Map<String, Object> main = (Map<String, Object>) weatherData.get('main');
            List<Object> weatherArray = (List<Object>) weatherData.get('weather');
            Map<String, Object> weather = (Map<String, Object>) weatherArray[0];
            
            Double temperature = (Double) main.get('temp');
            Double humidity = (Double) main.get('humidity');
            String description = (String) weather.get('description');
            String mainWeather = (String) weather.get('main');
            
            // Format the weather data as a readable string
            String climaActual = mainWeather + ' - ' + description +
                ', Temperatura: ' + temperature.intValue() + '°C' +
                ', Humedad: ' + humidity.intValue() + '%';
            
            System.debug('Weather data for ' + cityName + ': ' + climaActual);
            return climaActual;
            
        } catch (Exception e) {
            System.debug('Error processing weather data for ' + cityName + ': ' + e.getMessage());
            return 'Error procesando datos del clima';
        }
    }
    
    
}