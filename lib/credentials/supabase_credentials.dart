import 'package:supabase/supabase.dart';

class SupabaseCredentials {
  static const String APIKEY =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJveGdsYnRpcGRxenVlY3RiYXJuIiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTUzODYyMzMsImV4cCI6MjAxMDk2MjIzM30.zSVs1oevz9eMsq3o6vXPErW8sNWtOCgFKylkmPAQsWU';
  static const String APIURL = 'https://boxglbtipdqzuectbarn.supabase.co';

  static SupabaseClient supabaseClient = SupabaseClient(APIKEY, APIURL);

  static initialize({required String url, required String anonKey}) {}
}
