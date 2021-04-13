# gui.py
from kivy.app import App
from kivy.uix.boxlayout import BoxLayout
from kivy.uix.button import Button
from kivy.uix.textinput import TextInput
from kivy.uix.label import Label
import brownie
from brownie import config, network, DuelPoints, JustaDuel, MockV3Aggregator
import numpy as np

DUELPOINTS_KOVAN_ADDRESS = "0x17116318342D37F7cE4e8B3Fa48351d4E680B287"
JUSTADUEL_KOVAN_ADDRESS = "0xeC6Bb1C730B51F7E1F73797dc10f477e09c66D24"

DUELPOINTS_RINKEBY_ADDRESS = "0xa5c6eCCF4A18bF88976aA84E26Ac3695AA886C86"
JUSTADUEL_RINKEBY_ADDRESS = "0x4C1DFA89c4103f0f87b930dCE14ee3A67CF198c1"

ERR_MSG = ""

card_type = ["NONE", "BASE", "SWAP", "LEND", "LINK"]
coin_list = ["ETH/USD", "UNI/USD", "COMP/USD", "LINK/USD"]
button_format = {"font_size": 30, "pos_hint": {"center_x": 0.5, "center_y": 0.5}}
textinput_format = {"multiline": True, "halign": "left", "font_size": 20}

def seed_display(sid, info):
    dir_type = "long" if info[2] else "short"
    return  f"id: {sid}\n"+ \
            f"price: {info[1]}\n"+ \
            f"type: {dir_type}\n"+ \
            f"timestamp: {info[3]}"

def card_display(cid, info):
    return  f"id: {cid}\n"+ \
            f"power: {info[1]}\n"+ \
            f"type: {card_type[info[2]]}\n"+ \
            f"interval: {info[3]}"

class MainApp(App):
    def build(self):
        #--- contract setup
        self.dev_account = brownie.run("deploy", "get_dev_account")
        self.now_network = network.show_active()
        if self.now_network == "development":
            self.duc, self.dup, self.aggs = brownie.run("deploy")
        elif self.now_network in config["networks"]:
            self.dup = DuelPoints.at(config["networks"][self.now_network]["duel_points_address"])
            self.duc = JustaDuel.at(config["networks"][self.now_network]["justa_duel_address"])
            self.aggs = [MockV3Aggregator.at(addr) for addr in brownie.run("price_feed")]
        else:
            return Label(text="Invalid network", **button_format)

        #--- seed box
        seed_box = BoxLayout(orientation="vertical")
        self.agg_addr = TextInput(**textinput_format)
        self.agg_addr.text = self.aggs[0].address
        seed_box.add_widget(self.agg_addr)
        plant_seed_layout = BoxLayout(orientation="horizontal")
        long_seed_button = Button(text="long seed", **button_format)
        long_seed_button.bind(on_press=self.plant_seed)
        short_seed_button = Button(text="short seed", **button_format)
        short_seed_button.bind(on_press=self.plant_seed)
        plant_seed_layout.add_widget(long_seed_button)
        plant_seed_layout.add_widget(short_seed_button)
        seed_box.add_widget(plant_seed_layout)

        self.seed_info = TextInput(**textinput_format)
        show_seed_button = Button(text="show seed", **button_format)
        show_seed_button.bind(on_press=self.show_seed_info)
        seed_box.add_widget(self.seed_info)
        seed_box.add_widget(show_seed_button)

        self.seed_owner_addr = TextInput(**textinput_format)
        self.seed_owner_addr.text = self.dev_account.address
        get_seeds_button = Button(text="get seeds by owner", **button_format)
        get_seeds_button.bind(on_press=self.get_seeds_by_owner)
        seed_box.add_widget(self.seed_owner_addr)
        seed_box.add_widget(get_seeds_button) 

        #--- card box
        card_box = BoxLayout(orientation="vertical")
        self.seed_id = TextInput(**textinput_format)
        print_card_button = Button(text="print card", **button_format)
        print_card_button.bind(on_press=self.print_card)
        card_box.add_widget(self.seed_id)
        card_box.add_widget(print_card_button)

        self.card_info = TextInput(**textinput_format)
        show_card_button = Button(text="show card", **button_format)
        show_card_button.bind(on_press=self.show_card_info)
        card_box.add_widget(self.card_info)
        card_box.add_widget(show_card_button)

        self.card_owner_addr = TextInput(**textinput_format)
        self.card_owner_addr.text = self.dev_account.address
        get_cards_button = Button(text="get cards by owner", **button_format)
        get_cards_button.bind(on_press=self.get_cards_by_owner)
        card_box.add_widget(self.card_owner_addr)
        card_box.add_widget(get_cards_button) 

        #--- burn box
        burn_box = BoxLayout(orientation="vertical")
        update_button = Button(text="update price", **button_format)
        update_button.bind(on_press=self.update_price)
        self.card_id = TextInput(**textinput_format)
        burn_card_button = Button(text="burn card", **button_format)
        burn_card_button.bind(on_press=self.burn_card)
        turn_card_button = Button(text="turn card", **button_format)
        turn_card_button.bind(on_press=self.turn_card)
        self.duel_points_balance = Label(text=f"Duel Points\n{self.dup.balanceOf(self.dev_account)/10**self.dup.decimals()}", **button_format)
        self.eth_balance = Label(text=f"ETH balance\n{self.dev_account.balance()/10**18}", **button_format)
        burn_box.add_widget(update_button)
        burn_box.add_widget(self.card_id)
        burn_box.add_widget(burn_card_button)
        burn_box.add_widget(turn_card_button)
        burn_box.add_widget(self.duel_points_balance)
        burn_box.add_widget(self.eth_balance)

        #--- price box
        self.price_display = [0]*4
        price_box = BoxLayout(orientation="horizontal", size_hint=(1,0.2))
        for i in range(4):
            price_column = BoxLayout(orientation="vertical")
            price_column.add_widget(Label(text=f"{coin_list[i]}",**button_format))
            price_column.add_widget(TextInput(text=f"{self.aggs[i].address}", readonly=True, multiline=False, halign="center", font_size=20))
            self.price_display[i] = Label(text=f"{self.aggs[i].latestRoundData()[1]/10**self.aggs[i].decimals()}", **button_format)
            price_column.add_widget(self.price_display[i])
            price_box.add_widget(price_column)

        #--- main
        main_layout = BoxLayout(orientation="horizontal")
        main_layout.add_widget(seed_box)
        main_layout.add_widget(card_box)
        main_layout.add_widget(burn_box)
        
        large_layout = BoxLayout(orientation="vertical")
        large_layout.add_widget(price_box)
        large_layout.add_widget(main_layout)
        return large_layout

    def update_price(self, instance):
        if self.now_network == "development":
            changes = np.random.rand(4)/5-0.1
            [self.aggs[i].updateAnswer(self.aggs[i].latestAnswer()*(1+changes[i])) for i in range(4)]
        for i in range(4):
            self.price_display[i].text = f"{self.aggs[i].latestRoundData()[1]/10**self.aggs[i].decimals()}"

    def plant_seed(self, instance):
        try:
            tx = self.duc.plantSeed(self.agg_addr.text, instance.text[:4] == "long", {"from":self.dev_account})
            sid = tx.events["NewSeed"]["seedId"]
            self.agg_addr.text = f"Seed {sid} planted!"
            self.seed_info.text = seed_display(sid, self.duc.seeds(sid))
            self.eth_balance = Label(text=f"ETH balance\n{self.dev_account.balance()}")
        except (brownie.exceptions.VirtualMachineError, ValueError):
            self.agg_addr.text = ERR_MSG

    def show_seed_info(self, instance):
        try:
            sid = int(self.seed_info.text)
            self.seed_info.text = seed_display(sid, self.duc.seeds(sid))
        except (brownie.exceptions.VirtualMachineError, ValueError):
            self.seed_info.text = ERR_MSG

    def get_seeds_by_owner(self, instance):
        try:
            seed_ids = self.duc.getSeedsByOwner(self.seed_owner_addr.text)
            self.seed_owner_addr.text = ", ".join([str(sid) for sid in seed_ids])
        except (brownie.exceptions.VirtualMachineError, ValueError):
            self.seed_owner_addr.text = self.dev_account.address

    def print_card(self, instance):
        try:
            tx = self.duc.printCard(int(self.seed_id.text), {"from":self.dev_account})
            cid = tx.events["NewCard"]["cardId"]
            self.seed_id.text = f"Card {cid} planted!"
            self.card_info.text = card_display(cid, self.duc.cards(cid))
            self.eth_balance = Label(text=f"ETH balance\n{self.dev_account.balance()}")
        except (brownie.exceptions.VirtualMachineError, ValueError):
            self.seed_id.text = ERR_MSG

    def show_card_info(self, instance):
        try:
            cid = int(self.card_info.text)
            self.card_info.text = card_display(cid, self.duc.cards(cid))
        except (brownie.exceptions.VirtualMachineError, ValueError):
            self.card_info.text = ERR_MSG

    def get_cards_by_owner(self, instance):
        try:
            card_ids = self.duc.getCardsByOwner(self.card_owner_addr.text)
            self.card_owner_addr.text = ", ".join([str(cid) for cid in card_ids])
        except (brownie.exceptions.VirtualMachineError, ValueError):
            self.card_owner_addr.text = self.dev_account.address

    def burn_card(self, instance):
        try:
            self.duc.burnCard(int(self.card_id.text), {"from":self.dev_account})
            self.duel_points_balance.text = f"Duel Points\n{self.dup.balanceOf(self.dev_account)/10**self.dup.decimals()}"
            self.card_id.text = f"Card {self.card_id.text} burned!"
            self.eth_balance = Label(text=f"ETH balance\n{self.dev_account.balance()}")
        except (brownie.exceptions.VirtualMachineError, ValueError):
            self.card_id.text = ERR_MSG

    def turn_card(self, instance):
        try:
            self.duc.turnCard(int(self.card_id.text), {"from":self.dev_account})
            self.duel_points_balance.text = str(self.dup.balanceOf(self.dev_account)/10**self.dup.decimals())
            self.card_id.text = f"Card {self.card_id.text} turned!"
            self.eth_balance = Label(text=f"ETH balance\n{self.dev_account.balance()}")
        except (brownie.exceptions.VirtualMachineError, ValueError):
            self.card_id.text = ERR_MSG

def main():
    MainApp().run()