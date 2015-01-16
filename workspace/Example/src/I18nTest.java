import static org.junit.Assert.*;

import org.junit.Test;


public class I18nTest {

	@Test
	public void testAbbreviate() {
		assertEquals("i18n", I18n.abbreviate("internationalization"));
		assertEquals("l10n", I18n.abbreviate("localization"));
		assertEquals("fly", I18n.abbreviate("fly"));
		assertEquals("a2y", I18n.abbreviate("ally"));
	}

	@Test
	public void testAbbreviations() {
		I18n i18n = new I18n();
		i18n.addAbbreviation("compute");
		i18n.addAbbreviation("confuse");
		assertEquals("c5e", i18n.getAbbreviation("compute"));
		assertEquals("confuse", i18n.getAbbreviation("confuse"));
		assertEquals("compare", i18n.getAbbreviation("compare"));
	}

}
