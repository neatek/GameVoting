// www.sourcemodplugins.org/smlib/
String_ToLower(const String:input[], String:output[], size)
{
	size--;

	int x=0;
	while (input[x] != '\0' || x < size) {
		
		if (IsCharUpper(input[x])) {
			output[x] = CharToLower(input[x]);
		}
		else {
			output[x] = input[x];
		}
		
		x++;
	}

	output[x] = '\0';
}