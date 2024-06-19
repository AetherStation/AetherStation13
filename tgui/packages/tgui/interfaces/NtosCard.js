import { useBackend, useSharedState } from '../backend';
import { Box, Button, Dropdown, Input, NoticeBox, NumberInput, Section, Stack, Tabs } from '../components';
import { NtosWindow } from '../layouts';
export const NtosCard = (props) => {
  return (
    <NtosWindow
      width={500}
      height={670}>
      <NtosWindow.Content scrollable>
        <NtosCardContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

export const NtosCardContent = (props) => {
  const { act, data } = useBackend();
  const {
    authenticatedUser,
    access_on_card = [],
    access_on_chip = [],
    id_tier,
    has_id,
    have_id_slot,
    regions = [],
  } = data;

  const { templates } = data || {};

  if (!have_id_slot) {
    return (
      <NoticeBox>
        This program requires an ID slot in order to function
      </NoticeBox>
    );
  }

  const [
    selectedTab,
  ] = useSharedState("selectedTab", "login");

  const [
    selectedRegion,
    setSelectedRegion,
  ] = useSharedState("selectedRegion", regions["General"] ? "General" : Object.keys(regions)[0]);

  const button_tooltip = (access) => {
    let ret = [];
    if (access_on_chip.includes(access.id)) {
      ret.push("On access chip");
    }
    if (access.tier > id_tier) {
      ret.push("Requires tier " + access.tier + " ID card");
    }
    return ret.join(", ");
  };

  return (
    <>
      <Stack>
        <Stack.Item>
          <IDCardTabs />
        </Stack.Item>
        <Stack.Item width="100%">
          {(selectedTab === "login") && (
            <IDCardLogin />
          ) || (selectedTab === "modify") && (
            <IDCardTarget />
          )}
        </Stack.Item>
      </Stack>
      {(!!has_id && !!authenticatedUser) && (
        <Section
          title="Templates"
          mt={1} >
          <Dropdown
            width="100%"
            displayText={"Select a template..."}
            options={
              Object.keys(templates).map(k => {
                return k;
              })
            }
            onSelected={sel => act("PRG_template", {
              path: templates[sel],
            })} />
        </Section>
      )}
      <Stack mt={1}>
        <Stack.Item grow>
          {(!!has_id && !!authenticatedUser) && (
            <Box>
              <Section
                title="Access"
                buttons={(
                  <>
                    <Button
                      icon="check"
                      content="Grant Region"
                      color="good"
                      onClick={() => act('PRG_grant_region', { region: selectedRegion })} />
                    <Button
                      icon="undo"
                      content="Deny Region"
                      color="bad"
                      onClick={() => act('PRG_deny_region', { region: selectedRegion })} />
                  </>
                )}>
                <Stack>
                  <Stack.Item>
                    <Tabs vertical>
                      {Object.keys(regions).map((k) => {
                        return (
                          <Tabs.Tab
                            mr={1}
                            key={k}
                            selected={selectedRegion === k}
                            onClick={() => setSelectedRegion(k)}
                            altSelection
                          >{k}
                          </Tabs.Tab>
                        );
                      })}
                    </Tabs>
                  </Stack.Item>
                  <Stack.Item width="100%">
                    {regions[selectedRegion].map(access => {
                      return (
                        <Button
                          key={access.id}
                          tooltip={button_tooltip(access)}
                          disabled={
                            !access_on_chip.includes(access.id)
                            && access.tier > id_tier
                          }
                          color={
                            access_on_chip.includes(access.id)
                              ? "olive"
                              : ""
                          }
                          content={access.name}
                          selected={access_on_card.includes(access.id)}
                          onClick={() => {
                            if (access.tier > id_tier) { return; }
                            act('PRG_access', { access_target: access.id });
                          }} />
                      );
                    })}
                  </Stack.Item>
                </Stack>
              </Section>
            </Box>
          )}
        </Stack.Item>
      </Stack>
    </>
  );
};

const IDCardTabs = (props) => {
  const [
    selectedTab,
    setSelectedTab,
  ] = useSharedState("selectedTab", "login");

  return (
    <Tabs vertical fill>
      <Tabs.Tab
        minWidth={"100%"}
        altSelection
        selected={"login" === selectedTab}
        color={("login" === selectedTab) ? "green" : "default"}
        onClick={() => setSelectedTab("login")}>
        Login ID
      </Tabs.Tab>
      <Tabs.Tab
        minWidth={"100%"}
        altSelection
        selected={"modify" === selectedTab}
        color={("modify" === selectedTab) ? "green" : "default"}
        onClick={() => setSelectedTab("modify")}>
        Target ID
      </Tabs.Tab>
    </Tabs>
  );
};

export const IDCardLogin = (props) => {
  const { act, data } = useBackend();
  const {
    authenticatedUser,
    has_id,
    have_printer,
    authIDName,
  } = data;

  return (
    <Section
      title="Login"
      buttons={(
        <>
          <Button
            icon="print"
            content="Print"
            disabled={!have_printer || !has_id}
            onClick={() => act('PRG_print')} />
          <Button
            icon={authenticatedUser ? "sign-out-alt" : "sign-in-alt"}
            content={authenticatedUser ? "Log Out" : "Log In"}
            color={authenticatedUser ? "bad" : "good"}
            onClick={() => {
              act(authenticatedUser ? 'PRG_logout' : 'PRG_authenticate');
            }} />
        </>
      )}>
      <Stack wrap="wrap">
        <Stack.Item width="100%">
          <Button
            fluid
            ellipsis
            icon="eject"
            content={authIDName}
            onClick={() => act('PRG_ejectauthid')} />
        </Stack.Item>
        <Stack.Item width="100%" mt={1} ml={0}>
          Login: {authenticatedUser || "-----"}
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const IDCardTarget = (props) => {
  const { act, data } = useBackend();
  const {
    authenticatedUser,
    id_rank,
    id_owner,
    has_id,
    id_name,
    id_age,
  } = data;

  return (
    <Section title="Modify ID">
      <Button
        width="100%"
        ellipsis
        icon="eject"
        content={id_name}
        onClick={() => act('PRG_ejectmodid')} />
      {(!!has_id && !!authenticatedUser) && (
        <>
          <Stack mt={1}>
            <Stack.Item align="center">
              Details:
            </Stack.Item>
            <Stack.Item grow={1} mr={1} ml={1}>
              <Input
                width="100%"
                value={id_owner}
                onInput={(e, value) => act('PRG_edit', {
                  name: value,
                })} />
            </Stack.Item>
            <Stack.Item>
              <NumberInput
                value={id_age || 0}
                unit="Years"
                minValue={17}
                maxValue={85}
                onChange={(e, value) => { act('PRG_age', {
                  id_age: value,
                });
                }} />
            </Stack.Item>
          </Stack>
          <Stack>
            <Stack.Item align="center">
              Assignment:
            </Stack.Item>
            <Stack.Item grow={1} ml={1}>
              <Input
                fluid
                mt={1}
                value={id_rank}
                onInput={(e, value) => act('PRG_assign', {
                  assignment: value,
                })} />
            </Stack.Item>
          </Stack>
        </>
      )}
    </Section>
  );
};
