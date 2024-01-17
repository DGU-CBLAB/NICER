package hihi;
import javax.mail.Authenticator;
import javax.mail.PasswordAuthentication;

public class GoogleAuthentication extends Authenticator{
	PasswordAuthentication passAuth;
	
	public GoogleAuthentication() {
		passAuth = new PasswordAuthentication("@gmail.com", "password");
	}
	
	public PasswordAuthentication getPasswordAuthentication() {
		return passAuth;
	}
}
